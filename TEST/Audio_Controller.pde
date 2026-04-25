import processing.sound.*;
/* 

This class reads the input audio file and updates Data fields per frame
Has functions that will apply modifications to the audio determined by arguments sent by UI

Out Going Data Updates:
   *  FFT data -- frequency bands and intensity
   *  Beat Detection -- is beat Bool and intensity

Available effect features
    *  Wholistic and frequency based Volume control
    *  Reverb filter
    *  ...




Dependent on Minim library
*/
class AudioController
{

    //DATA DECLARATIONS ------------------------------------------------
    
    /*
    Audio source management
    */ 
    String song_name; //Eventually an argument right now test audio
    SoundFile audio; 

    
    FFT fft; //fourier transform object
    
    
     /*
    Outgoing Audio data

    * bool is_beat, int beat_amplitude for GUI
    * a copy of the fourier transform frequency bands. for GUI
        * FFT data will be a float array scaled 0 - 1.0 indicating amplitude for frequencies in range
          like a histogram would. Entirely private for internal processing only
        * HAS to be used on Raw audio data not filtered many internal functions and effects will be dependent on this
    *Bands is the final analyzed frequency ranges to be returned to the main program
        *Logarithmically adjusted to better reflect human audio perception.
    
    */
    
    private int num_freq = 8192;                        //required to be a power of 2 for the FFT to work
    private float [] frequencies = new float[num_freq]; // Stores frequency  amplitudes from the FFT
    private float [] smooth = new float[num_freq];      //stores smoothed out FFT values scaled to a history adjusted amplitude peak
    float[] peak = new float[num_freq]; // used to compare recent audio intensity levels for scaling to the the standard range

    private int num_bands = 12;
    private float [] bands = new float[num_bands]; //contains final logarithmically adjusted frequencies bands

    private boolean is_beat = false;            //for GUI to determine if a beat action is needed
    private float beat_amplitude;               //intensity of the beat action
    private float beat_peak = 0;                //recent volume peak for the beat relevant audio range
    private float beat_decay = 0.99;            // volume decay rate
    private float beat_duration = 0;            //How long the beat lasts
    private float beat_duration_decay = 0.87;   //How fast it fades


    /*
    Data inputs
    
    Almost all data inputs will be in the form of a float scaled 0.0-1.0
    This will allow the UI sliders to send an easy to manage signal and the audio controller will scale
    the number and apply affects accordingly:
        * All volume sliders
        * Reverb: 0 none 1 max (whatever is the limit for what sounds ok)
        * Pitch shift: centered on .5  
            * < .5 shifts down
            * > .5 shifts up probably 
            * audio is nonlinear so this may be a bit complex
        * Playback speed (this one can scale to 2.0 maybe)
            
        *Paused bools
    */
    
    private float [] freq_volume = new float [num_freq]; //volumes for each frequency band
    private float master_volume = 1;

    private float reverb_strength = 0; //not necessary unless we need to pull the active reverb for whatever reason
    private Reverb rvb;

    private boolean paused; 
    
    

    //call for clean memory deallocation of currently active file
    void dispose()
    {
        if (audio != null)
        {
            audio.stop();
            audio = null;
        }
    }

    //Loads song file into the Controller
    void loadSong (PApplet app, String fname) // For the applet just type 'this' to get a reference to the running process
    {
        dispose();
        audio = new SoundFile(app, fname);
        fft.input(audio);
        
    }

    
    //Constructor for the Controller
    AudioController(PApplet app) // For the applet just type 'this' to get a reference to the running process
    {
        fft = new FFT(app, num_freq);
        rvb = new Reverb(app);

        for (int i = 0; i < freq_volume.length; i++) freq_volume[i] = 1; //initizlize frequency band volume
        for (int i = 0; i < smooth.length; i++) smooth[i] = 0;
        for (int i = 0; i < peak.length; i++) peak[i] = .5;

    }

    // -------------------------------------------------------------------------------
    // Analysis-----------------------------------------------------------------------
    // -------------------------------------------------------------------------------


    /*Update 
            Called in draw to make sure that visualizations reflect the audio playing on that frame
            Updates all import outgoing data like FFT bands and beat detection
    */
    void update()
    {
        
        if(!audio.isPlaying()) audio.play();
        fft.analyze(frequencies);//stores the frequency bands. Needs rescaled values will be ~ .05
        float[] normalized = new float[num_freq];

        for (int i = 0; i < num_freq; i++) //normalize each frequency band in a range of 0-1
        {
            //adaptively chooses a highest volume.
            //If old peak is chosen it will slowly decay 
            //to react to volume shifts in the music
            peak[i] = max((peak[i] * .99), frequencies[i]); 
            peak[i] = max(peak[i], .001);  //protects div by zero


            normalized[i] =  frequencies[i]/peak[i];          //rescales to a range 0 - 1 based on relative loudness to recent samples
            normalized [i] = constrain(normalized[i], 0, 1);  //just in case I'm not seeing something

            smooth[i] = lerp(smooth[i], normalized[i], .02);
            
        }
        
        
        map_bands();// readjusts to a logarithmic scale
        detectBeat();
    }

    /* 
    Uses an initial volume based threshold to determine whether this update contains a beat. 
    Sets a time based on the amplitude of the the update. 
    Each following call will either decay the duration. Or refresh it on a new beat.

    The volume threshold is determiend dynamically so it also has a decay rate that allows it to adapt to change
    in accordance to volume dynamics. 

    Only scans bass volume ranges to for detection since that is where instruments like drums, bass guitar and other tempor setters
    reset
    */
    void detectBeat()
    {
    float bass_amp = (bands[1] + bands[2] + bands[3] + bands[3]) / 4;

    // Decay the recent peak between beats
    beat_peak = beat_peak * beat_decay;

    // Decay the beat duration
    beat_duration = beat_duration * beat_duration_decay;

    //Volume based beat detection
    if (bass_amp > beat_peak * 1.15)
    {
        beat_duration = max(beat_duration, bass_amp);  // Resets duration marker if there is already a new beat. 
        beat_peak = bass_amp;                          // Updates the most recent peak volume
    }

    is_beat = (beat_duration > 0.08);  // Only true if duration is still significant
    beat_amplitude = beat_duration;    // Use duration for amplitude instead
    }

    /* 
    Adjusts the FFT bins linear scale and plugs it into Bands that more closely resemble our perception
    */ 
    void map_bands ()
    {
        float base = 2; //Pitch usually follows a logarithm based on 2
        int index_tracker = 0;

        for (int i = 0; i < num_bands; i++)
        {
            int width = (int) pow(base, i); // approximate the amount of bins should go into bands on a logarithmic scale
            
            int start = index_tracker;  //the start of the bin range to avg
            int end = min(index_tracker + width, num_freq);  //the end of the bin range to avg. Protection from running past bins array

            float total = 0;    //traditional stuff for avg
            float amount = 0;   // *

            for(int j = start; j < end; j++) //avg bin values to plug into band
            {
                total += smooth[j];
                amount += 1;
            }

            bands[i] = (amount > 0) ? total/amount : 0;

            index_tracker = end; //update our tracker so we start at the right position in the next loop

            
            

            if (index_tracker  == num_freq - 1) break;
        }
    }


    
    //-------------------------------------------------------------------------------
    // Change Effects----------------------------------------------------------------
    //-------------------------------------------------------------------------------
    
    /*
    Takes in a single float 0-1 

    uses that number to scale the various arguments for reverb effects
    sets them and activates the reverb
    */
    void set_reverb(float strength)
    {
        strength = constrain(strength,0,1);
        reverb_strength = strength;

        if (strength > 0)
        {
            rvb.damp(strength * .5);                //Limits high notes
            rvb.room(map(strength, 0, 1, .2, .8));  //simulates room size of the echo effect
            rvb.wet(map(strength, 0, 1, 0, .6));    //general strength of the reverb


            rvb.process(audio);
        } else rvb.stop();
        
    }


    //-------------------------------------------------------------------------------
    //flow control-------------------------------------------------------------------
    //-------------------------------------------------------------------------------

    void pause() // toggle pause
    {
        if (paused) audio.play();
        else audio.pause();
    }

    void jump (int time) // time in seconds
    {
        audio.jump(time);
    }

    void set_speed (float sp) //updates speed. Currently will distort pitch.
    {
        audio.rate(sp);
    }


    //-----------------------------------------------------------------------------
    //Getters ---------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    float[] bands() {return bands;}
    

    int get_num_bands(){ return num_bands;}
   

    int get_num_freq() {return num_freq;}

    boolean get_is_beat() {return is_beat;}
    float get_beat_amplitude() {return beat_amplitude;}
    
    void start()
    {
        audio.play();
        println("Audio frames:", audio.frames());
        println(audio.duration());
        audio.amp(1);
    }
}