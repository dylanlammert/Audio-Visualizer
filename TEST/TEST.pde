
String[] fname = {"Still Feel - Half Alive.wav", "Clocks - Coldplay.mp3", "Live Concert - Thomas Day.mp3", "High Hopes - Panic! at the disco.mp3"} ;

AudioController ac;

int num_bands;
int bar_w; 
float reverb_strength = .0;

void setup()
{
    size(1000, 750);
    pixelDensity(1);
    

    


    ac  = new AudioController(this);
    ac.loadSong(this,fname[2]);
    

    

    num_bands = ac.num_bands;
    bar_w = width/num_bands;
    ac.start();

    
}

void draw()
{
    background(0);
    
    fill(255, 0, 0);

    ac.update();
    float [] b = ac.bands();
    for(int i = 0; i < ac.get_num_bands(); i++)
    {   
        
        float bar_h = (b[i] * (height * .5));
        rect(bar_w * i, height, bar_w, (int)-bar_h);
        //println(i, ac.bands[i]);
    }

    int radius = 50; 
    if (ac.get_is_beat()) 
    {
        fill(0, 255, 0);
        radius += 50 * ac.get_beat_amplitude();
        //println("beat", ac.get_beat_amplitude());
    }
    circle(100, 100, radius);

    
    
    
}

void keyReleased()
{
    if (key == CODED)
    {
        if (keyCode == UP)
        {
            reverb_strength += .1;
            ac.set_reverb(reverb_strength);
            println(reverb_strength);
        }

        if (keyCode == DOWN)
        {
            reverb_strength -= .1;
            ac.set_reverb(reverb_strength);
            println(reverb_strength);
        }
    }
}


//called on process close. Ensures clean memory deallocation. 
void stop()
{
    ac.dispose();
    super.stop();
}