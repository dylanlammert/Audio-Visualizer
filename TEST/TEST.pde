
String[] fname = {"Still Feel - Half Alive.mp3", "High Hopes - Panic! at the disco.mp3"} ;

AudioController ac;

int num_bands;
int bar_w; 


void setup()
{
    size(1000, 750);
    pixelDensity(1);
    


    ac  = new AudioController(this,fname[1]);
    num_bands = ac.num_bands;
    bar_w = width/num_bands;
    ac.start();

    
}

void draw()
{
    background(0);
    
    fill(255, 0, 0);
    
    ac.update();
    for(int i = 0; i < num_bands; i++)
    {   
        
        float bar_h = (ac.bands[i] * (height * .5));
        rect(bar_w * i, height, bar_w, (int)-bar_h);
        //println(i, ac.bands[i]);
    }
    
}