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
    effect nodes:
    MoogFilter isolate frequency ranges (imperfectly)

    Gain controls volume sensitivity

    Delay adds an echo (reverb)
    */

    private TickRate tick;

    private MoogFilter low;
    private MoogFilter mid;
    private MoogFilter high;

    private Gain lGain;
    private Gain mGain;
    private Gain hGain;

    private Delay lwet; //wetness refers to how proceessed a signal is
    private Delay mwet;
    private Delay hwet;

    private Summer lrvb; //merge wet and dry signals
    private Summer mrvb;
    private Summer hrvb;
    
    private Summer merge; //special node that can merge multiple audio inputs
    private Gain fullGain;
    private Delay fullWet;
    private Summer master;
   
    


    /*
    input data
    */
    float play_rate_base;

    
   

    
    
    //-------------------------------------------------------------------------------
    // Memory management----------------------------------------------------------------
    //-------------------------------------------------------------------------------

    //call for clean memory deallocation of currently active file
    void clearSong()
    {
        if (audio != null)
        {
            audio.close();
        }
    }


    //Loads song file into the Controller
    public void loadSong (String filePath) // For the applet just type 'this' to get a reference to the running process
    {
        if (audio != null) // if this isn't the first load
        {
            audio.pause();
            audio.close();
            audio = new FilePlayer(minim.loadFileStream(filePath)); //without this is somehow remembered old song
            audio.patch(tick);
            
        } else // if this is the first load
        {
            audio = new FilePlayer(minim.loadFileStream(filePath));
        
            /*
            create and branch audio inputs for parallel effects
            Merge them through a summer, and then process through master effects
            to feed the final audio output and analysis
            */

            audio.patch(tick);

            tick.patch(low); 
            low.patch(lGain);  
            lGain.patch(lwet);
            lwet.patch(lrvb); //    merge wet and dry signals of the reverb process
            lGain.patch(lrvb);//    |
            lrvb.patch(merge);//    |
            
            tick.patch(mid);
            mid.patch(mGain);
            mGain.patch(mwet);
            mwet.patch(mrvb); //    merge wet and dry signals of the reverb process
            mGain.patch(lrvb);//    |
            mrvb.patch(merge);//    |
            
            tick.patch(high);
            high.patch(hGain);
            hGain.patch(hwet);
            hwet.patch(hrvb); //    merge wet and dry signals of the reverb process
            hGain.patch(lrvb);//    |
            hrvb.patch(merge);//    |
            
            merge.patch(fullGain);
            fullGain.patch(fullWet);
            fullGain.patch(master);
            fullWet.patch(master);

            master.patch(out);
        }
        


        
        fft = new FFT(out.bufferSize(), out.sampleRate());
        fft.logAverages(11, 1); //this automatically fixes the log issue and will give us 12 frequncy bands that are nice visually
        fft.window((FFT.HAMMING)); //windowing functin that cleans up the sound wave going into FFT
       


        play_rate_base = audio.sampleRate();
        smooth = new float[fft.avgSize()];
        peak = new float[fft.avgSize()];
        for (int i = 0; i < smooth.length; i++) smooth[i] = 0;
        for (int i = 0; i < peak.length; i++) peak[i] = .5;
         
        audio.loop();
    }

    
    //Constructor for the Controller
    AudioController(PApplet app) // For the applet just type 'this' to get a reference to the running process
    {
        application = app;
        minim = new Minim(app);
        out = minim.getLineOut();   //create the audio output object

        tick = new TickRate();
        
        low  = new MoogFilter(300, .5, MoogFilter.Type.LP);
        mid  = new MoogFilter(1500, .6, MoogFilter.Type.BP);
        high = new MoogFilter(4000, .5, MoogFilter.Type.HP);

        lGain = new Gain(0);
        mGain = new Gain(0);
        hGain = new Gain(0);

        lwet = new Delay(1, .1, true, false);
        mwet = new Delay(1, .1, true, false);
        hwet = new Delay(1, .1, true, false);

        

        lrvb = new Summer();
        
        mrvb = new Summer();
        hrvb = new Summer();


        merge = new Summer();
        fullGain = new Gain(0);
        fullWet = new Delay(1, .1, true, false);
        fullWet.setDelTime(0); 

       
        master  = new Summer();
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
        //audio.patch(low).patch(mid).patch(high);
        fft.forward(out.mix);//stores the frequency bands. Needs rescaled values will be ~ .05
        
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
    void masterGain(float strength)
    {
        if (strength != 0) 
        {
            strength = constrain(strength,0,1);
            strength = map(strength, 0, 1, -12, 12);
            fullGain.setValue(strength);
        } else fullGain.setValue (-60);
        
    }

    void lowGain(float strength)
    {
        if (strength != 0) 
        {
            strength = constrain(strength,0,1);
            strength = map(strength, 0, 1, -12, 12);
            lGain.setValue(strength);
        } else lGain.setValue (-60);
    }

    void midGain(float strength)
    {
        if (strength != 0) 
        {
            strength = constrain(strength,0,1);
            strength = map(strength, 0, 1, -12, 12);
            mGain.setValue(strength);
        } else mGain.setValue (-60);
    }
    void highGain(float strength)
    {
        if (strength != 0) 
        {
            strength = constrain(strength,0,1);
            strength = map(strength, 0, 1, -12, 12);
            hGain.setValue(strength);
        } else hGain.setValue (-60);
    }

    void masterReverb(float strength)
    {
        strength = constrain(strength,0,1);
        float time = map(strength, 0, 1, 0, .3);
        float amp = map(strength, 0, 1, 0, .2);


        fullWet.setDelTime(time);
        fullWet.setDelAmp(amp);
    }
     void lowReverb(float strength)
    {
        strength = constrain(strength,0,1);
        float time = map(strength, 0, 1, 0, .3);
        float amp = map(strength, 0, 1, 0, .2);


        mwet.setDelTime(time);
        mwet.setDelAmp(amp);
    }
     void midReverb(float strength)
    {
        strength = constrain(strength,0,1);
        float time = map(strength, 0, 1, 0, .3);
        float amp = map(strength, 0, 1, 0, .2);


        mwet.setDelTime(time);
        mwet.setDelAmp(amp);
    }
     void highReverb(float strength)
    {
        strength = constrain(strength,0,1);
        float time = map(strength, 0, 1, 0, .3);
        float amp = map(strength, 0, 1, 0, .2);


        hwet.setDelTime(time);
        hwet.setDelAmp(amp);
    }

    //-------------------------------------------------------------------------------
    //flow control-------------------------------------------------------------------
    //-------------------------------------------------------------------------------

    void pause()                // toggle pause
    {
        if (!audio.isPlaying())audio.play();
        else audio.pause();
    }

    void offset_time (int time) //time in mili seconds can be negative
    {
        audio.skip(time);
    }

    void set_speed (float sp)   //updates speed. Currently will distort pitch.
    {
        tick.value.setLastValue(sp);
    }

    void jump(float time)    // for progress bar j
    {
        audio.cue(floor(time));
        audio.play();
    }

    

    //-----------------------------------------------------------------------------
    //Getters ---------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    float[] bands()            {return smooth;}
    int get_num_bands()        {return fft.avgSize();}

    boolean get_is_beat()      {return is_beat;}
    float get_beat_amplitude() {return beat_amplitude;}

    boolean is_play()          {return audio.isPlaying();}
    float get_time()           {return audio.position();}
    float get_duration()       {return audio.length();}   

}
