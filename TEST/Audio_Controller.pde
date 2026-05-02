import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;


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
    PApplet application; 
    Minim minim; 
    String song_name; //Eventually an argument right now test audio
    FilePlayer audio; //original audio source
    AudioOutput out; //merge of filter and effects.
    
    
    /*
     analysis variables and objects
    */
    FFT fft; //fourier transform object

    private float[] smooth;       //stores smoothed out FFT values scaled to a history adjusted amplitude peak
    private float[] peak;         //used to compare recent audio intensity levels for scaling to the the standard range


    private boolean is_beat = false;            //for GUI to determine if a beat action is needed
    private float beat_amplitude;               //intensity of the beat action
    private float beat_peak = 0;                //recent volume peak for the beat relevant audio range
    private float beat_decay = 0.99;            // volume decay rate
    private float beat_duration = 0;            //How long the beat lasts
    private float beat_duration_decay = 0.87;   //How fast it fades


    /* 
    effect data
    */
   MoogFilter low;
   MoogFilter mid;
   MoogFilter high;


    /*
    input data
    */
    
    private float master_volume = 1;

    private float reverb_strength = 1; //not necessary unless we need to pull the active reverb for whatever reason
   

    
    
    //-------------------------------------------------------------------------------
    // Memory management----------------------------------------------------------------
    //-------------------------------------------------------------------------------

    // //call for clean memory deallocation of currently active file
    // void dispose()
    // {
    //     if (audio != null)
    //     {
    //         audio.paus();
    //         audio.removeFromCache();
    //     }
    // }


    //Loads song file into the Controller
    public void loadSong (String filePath) // For the applet just type 'this' to get a reference to the running process
    {
        audio = new FilePlayer(minim.loadFileStream(filePath));
        audio.loop();
        audio.setSampleRate(2058);

        out = minim.getLineOut();   //create the audio output object
    
        fft = new FFT(2048, 44100);
        fft.logAverages(11, 1); //this automatically fixes the log issue and will give us 12 frequncy bands that are nice visually
        fft.window((FFT.HAMMING)); //windowing functin that cleans up the sound wave going into FFT
       

        smooth = new float[fft.avgSize()];
        peak = new float[fft.avgSize()];
        for (int i = 0; i < smooth.length; i++) smooth[i] = 0;
        for (int i = 0; i < peak.length; i++) peak[i] = .5;
         
        println("song chosen ", filePath);
        audio.play();
    }

    
    //Constructor for the Controller
    AudioController(PApplet app) // For the applet just type 'this' to get a reference to the running process
    {
        application = app;
        minim = new Minim(app);
        
        low  = new MoogFilter(200, .7, MoogFilter.Type.LP);
        mid  = new MoogFilter(1000, .8, MoogFilter.Type.BP);
        high = new MoogFilter(5000, .5, MoogFilter.Type.HP);
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
        audio.patch(low).patch(mid).patch(high);
        fft.input(out);//stores the frequency bands. Needs rescaled values will be ~ .05
        
        float[] normalized = new float[fft.avgSize()];

        for (int i = 0; i < fft.avgSize(); i++) //normalize each frequency band in a range of 0-1
        {
            //adaptively chooses a highest volume.
            //If old peak is chosen it will slowly decay 
            //to react to volume shifts in the music
            peak[i] = max((peak[i] * .99), fft.getAvg(i)); 
            peak[i] = max(peak[i], .001);  //protects div by zero


            normalized[i] =  fft.getAvg(i)/peak[i];          //rescales to a range 0 - 1 based on relative loudness to recent samples
            normalized [i] = constrain(normalized[i], 0, 1);  //just in case I'm not seeing something

            smooth[i] = lerp(smooth[i], normalized[i], .01);
            
        }
        
        
        
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
    float bass_amp = (smooth[1] + smooth[2] + smooth[3] + smooth[3]) / 4;

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

   

    
    //-------------------------------------------------------------------------------
    // Change Effects----------------------------------------------------------------
    //-------------------------------------------------------------------------------
    
    /*
    Takes in a single float 0-1 

    uses that number to scale the various arguments for reverb effects
    sets them and activates the reverb
    */
    // void set_reverb(float strength)
    // {
    //     strength = constrain(strength,0,1);
    //     reverb_strength = strength;

    //     if (strength > 0)
    //     {
    //         rvb.damp(strength * .5);                //Limits high notes
    //         rvb.room(map(strength, 0, 1, .2, .8));  //simulates room size of the echo effect
    //         rvb.wet(map(strength, 0, 1, 0, .6));    //general strength of the reverb


    //         rvb.process(audio);
    //     } else rvb.stop();
        
    // }

    // void set_volume(float strength)
    // {
    //     strength = constrain(strength,0,1);
    //     master_volume = (strength);
    //     //audio.amp(strength);
    // }

    //-------------------------------------------------------------------------------
    //flow control-------------------------------------------------------------------
    //-------------------------------------------------------------------------------

    // void pause()                // toggle pause
    // {
    //     if (!audio.isPlaying())audio.play();
    //     else audio.pause();
    // }

    // void offset_time (int time) //time in seconds can be negative
    // {
    //     audio.jump(audio.position() + time);
    // }

    // void set_speed (float sp)   //updates speed. Currently will distort pitch.
    // {
    //     audio.rate(sp);
    // }

    // void jump(float percent)    // for progress bar jumps expects 0-1
    // {
    //     percent = constrain(percent, 0.0, 1.0);
    //     audio.jump(percent * (audio.position()/audio.duration())); // automatically rescales. 
    // }

    // void change_rate(float speed) //shifts pitch as a side effect.
    // {
    //     audio.rate(speed);
    // }
    

    //-----------------------------------------------------------------------------
    //Getters ---------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    float[] bands()             {return smooth;}
    int get_num_bands()        {return fft.avgSize();}

    boolean get_is_beat()      {return is_beat;}
    float get_beat_amplitude() {return beat_amplitude;}

    boolean is_play()          {return audio.isPlaying();}
    float get_time()           {return audio.position();}
    //float get_duration()     {return audio.duration();}
    
    // void start()
    // {
    //     audio.play();
    //     println("Audio frames:", audio.frames());
    //     println(audio.duration());
    //     audio.amp(1);
    // }
}

