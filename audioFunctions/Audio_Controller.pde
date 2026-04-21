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
    This seems to be a minim based approoach sound library will require a different approach
    */ 
    String song_name; //Eventually an argument right now test audio
    SoundFile audio; 

    int num_freq = 8; //required to be a power of 2 for the FFT to work
    FFT fft; //fourier transform object
    

    float [] frequencies = new float[num_freq]; // Stores frequency band amplitudes from the FFT
    private float [] freq_volume = new float [num_freq]; //volumes for each frequency band
    float master_volume = 1;
    
    float[] peak = new float[num_freq]; // used to compare recent audio intensity levels for scaling to the the standard range

    /*
    Outgoing Audio data

    * bool is_beat, int beat_amplitude for GUI
    * a copy of the fourier transform frequency bands. for GUI
        * FFT data will be a float array scaled 0 - 1.0 indicating amplitude for frequencies in range
          like a histogram would
        * HAS to be used on Raw audio data not filtered many internal functions and effects will be dependent on this
    */
    
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
            
    Paused bools
    */

    /*
     Useful internal functions:

        * Update 
            Called in draw to make sure that visualization reflect the audio playing on that frame
            Updates all import outgoing data like FFT bands and beat detection

        * Low pass filters for noise (though since we are probably using final sonf mp3's for testing this may not become relevant)
            Potentially important because auditory noise could distort visualizations

        * Time Jumping for the progress bar clicks.

        * Audio Effects:
            * Reverb
            * Pitch shifting

    */

    //Loads song file into the Controller
    void loadSong (PApplet app, String fname) // For the applet just type 'this' to get a reference to the running process
    {
        audio = new SoundFile(app, fname);
        fft.input(audio);
    }

    //Constructor for the Controller
    AudioController(PApplet app, String fname) // For the applet just type 'this' to get a reference to the running process
    {
        fft = new FFT(app, num_freq);
        
        song_name = fname;
        loadSong(app, song_name);

        for (int i = 0; i < freq_volume.length; i++) freq_volume[i] = 1; //initizlize frequency band volume
    }

    void update()
    {
        frequencies = fft.analyze(frequencies);//stores the frequency bands. Needs rescaled values will be ~ .05
        float currentPeak = max(frequencies); //highest volume in current sample

        

    }
        
}