
String[] fname = {"Still Feel - Half Alive.mp3", "High Hopes - Panic! at the disco.mp3"} ;

AudioController ac;

int num_freq;
int bar_w; 


void setup()
{
    size(1000, 750);
    pixelDensity(1);
    


    ac  = new AudioController(this,fname[0]);
    num_freq = ac.num_freq;
    bar_w = width/num_freq;
    ac.start();

    
}

void draw()
{
    background(0);
    
    fill(255, 0, 0);
    
    ac.update();
    for(int i = 0; i < num_freq; i++)
    {   
        
        float bar_h = (ac.smooth[i] * (height * .5));
        rect(bar_w * i, height, bar_w, (int)-bar_h);
    }
    //println(ac.frequencies[0]);
}