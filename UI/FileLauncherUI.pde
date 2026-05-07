// This is the class declaration for all file launcher UI functions and helper functions
import java.io.*;
/**
    Notes: 
    -----
    * will most likely need a way to remember context of the current
      selected path
*/
class FileLauncherUI extends Section{
    // this is the current path to a file or folder
    File currentFile, currentFolder, potentialCurrentFile;
    String currentButton = "";
    int currentButtonX = 0, currentButtonY;
    int currentButtonWidth = 0, currentButtonHeight;
    // array of accepted extensions so that I can iterate through them
    String[] acceptedExtensions = {".mp3", ".wav"};
    private File[] accessableFiles = new File[0];
    //PImage openFolderIcon;
    


    FileLauncherUI(float sx, float sy, float ex, float ey, color col, int x, int y){
        super(sx, sy, ex, ey, col, x, y);
        //openFolderIcon = loadImage("folderOpen.png");
    }
    /**
        @brief This is the controller for all of the drawable functions
    */
    void display(){
        int fileY = 25;
        super.display();
        
        if(currentFolder == null) {
            selectFileButton();
        } else {
            // display current folder directory and contents
            fill(255,255,255);
            currentFolderUI();
            for(int i = 0; i < accessableFiles.length; i++){
                fileCard(accessableFiles[0], fileY);
                fileY += 25;
            }
            
            //text(currentFolderPath, centerX - (w - 12)/ 2, centerY, textWidth(currentFolderPath), 30);
        }
    }

    // this probably needs testing for folders within folders
    // could be nice to update an image on the side depending on file type
    void currentFolderUI(){
        String label = currentFolder.getName();
        
        
        fill(colorTheme.tertiaryBackground);
        rect(0, 0, int(endX), 24);
        fill(colorTheme.primaryText);
        textAlign(LEFT);
        text(label, 12,6,int(endX), 24);
        textAlign(CENTER);
        // change working Directory Button
        newFolderButton();
    }

    void newFolderButton(){
        String newFolder = "new project";
        if(overButton(int(endX - textWidth(newFolder) - 6), 0, -1, int(textWidth(newFolder) + 6 + 24), 24 )){
            fill(colorTheme.primaryText);
            currentButton = "new project";
            currentButtonX = int(endX - textWidth(newFolder) - 6);
            currentButtonY = 0;
            currentButtonWidth = int(textWidth(newFolder) + 6 + 24);
            currentButtonHeight = 24;
            noStroke();
            rect(endX - textWidth(newFolder) - 6, 0, textWidth(newFolder) + 6 + 24,24);
            textAlign(LEFT, CENTER);
            fill(colorTheme.linkColor);
            text(newFolder, endX - textWidth(newFolder) - 6, 0, textWidth(newFolder) + 6, 20);
        //make a white plus sign that follows the text;
        }else {
            fill(colorTheme.linkColor);
            
            noStroke();
            rect(endX - textWidth(newFolder) - 6, 0, textWidth(newFolder) + 6 + 24,24);
            textAlign(LEFT, CENTER);
            fill(colorTheme.primaryText);
            text(newFolder, endX - textWidth(newFolder) - 6, 0, textWidth(newFolder) + 6, 20);
        //make a white plus sign that follows the text;
        }
        
    }

    void fileCard(File filePath, int startY) {
        String label = filePath.getName();
        if(overButton(0, startY,-1, int(endX), 25 )){
            fill(colorTheme.hoverButton);
            potentialCurrentFile = filePath;
            currentButton = "individual file";
            currentButtonX = 0;
            currentButtonY = startY;
            currentButtonHeight = 25;
            currentButtonWidth = int(endX);
        }else{
            fill(colorTheme.primaryBackground);
        }
        rect(0,startY, int(endX), 20);
        fill(255);
        textAlign(LEFT, CENTER);
        text(label,12, startY, int(endX), 25);
    }

    void setAccessableFiles(File[] fileList){
        accessableFiles = fileList;
    }

    void selectFileButton(){
        int textBoxStart = int(centerX - (w - 12) / 2);
        int textLength = int(w - 24);
        int textHeight = 30;
        String label = "Open a new folder...";
        // drawable
        //rect()
        
        textAlign(CENTER);
        fill(colorTheme.linkColor);
        text(label, textBoxStart, centerY, textLength, textHeight);
        if(overButton(textBoxStart, int(centerY), -1, textLength, textHeight)) {
            currentButton = "open file button";
            currentButtonX = textBoxStart;
            currentButtonY = int(centerY);
            currentButtonWidth = textLength;
            currentButtonHeight = textHeight;
            stroke(colorTheme.linkColor);
            strokeWeight(1);
            line(centerX - (textWidth(label) / 2) - 6, centerY + 2 + textAscent(), centerX + textWidth(label) / 2, centerY + 2 + textAscent());
            stroke(0);
            cursor(HAND);
        } else {
            cursor(ARROW);
        }
    }

    void selectFunction(){
        selectFolder("Select a file or folder to visualize audio", "folderSelected");
    }

    
    File[] getFolderContents( File folderPath){
        // if there is no folder path return a null file array
        println("attemping to grab the folder's content");
        FilenameFilter acceptedFiles = new FilenameFilter(){
            public boolean accept(File dir, String name) {
                name = name.toLowerCase();
                for(int i = 0; i < acceptedExtensions.length; i++ ){
                    if (name.endsWith(acceptedExtensions[i])){
                        return true;
                    } 
                }
                return false;
            }
        };
        // show a folder structure for current folder
        // if there are no files that meet the filter return an empty file and 
        // print that there were no files that met the filter
        File[] fileList = folderPath.listFiles(acceptedFiles); 
        if(fileList != null) {
            println(fileList);
            return fileList;
        }else {
            println("No accepted files found within specified folder");
            return new File[0];
        }
    }
    
   
}
