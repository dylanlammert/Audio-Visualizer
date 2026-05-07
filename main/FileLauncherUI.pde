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

    // vars to determine clickable button
    String currentButton = "";
    int currentButtonX = 0, currentButtonY;
    int currentButtonWidth = 0, currentButtonHeight;
    // array of accepted extensions so that I can iterate through them
    String[] acceptedExtensions = {".mp3", ".wav"};
    private File[] accessableFiles = new File[0];

    // scroll state variables
    float scrollY = 0;
    int scrollRate = 24;  
    int textHeight = 24; 
    int currentFolderUIHeight = 32; 
    int padding = 12;

    /**
        @brief class constructor that calls the super class constructor
    */
    FileLauncherUI(float sx, float sy, float ex, float ey, color col, int x, int y){
        super(sx, sy, ex, ey, col, x, y);
    }

    /**
        @brief This is the controller for all of the drawable functions
    */
    void display(){
        //int fileY = 24;
        super.display();
        
        if(currentFolder == null) {
            selectFileButton();
        } else {
            // display current folder directory and contents
            fill(255,255,255);
            scrollableList();
            currentFolderUI();
        }
    }

    /**
        @brief this is the UI for the current folder bar shown at the top of the fileLauncher screen

        TODO
        ----------
        * allow child folders to be shown in the launcher
        * create an image that shows what the file type is
    */
    void currentFolderUI(){
        String label = textChop(currentFolder.getName(), int(endX - textWidth("new project") - 6 - padding));
        
        fill(colorTheme.secondaryBackground);
        rect(0, 0, int(endX), currentFolderUIHeight + padding);
        fill(colorTheme.primaryText);
        textAlign(LEFT, CENTER);
        textFont(headerFont);
        textSize(24);
        text(label, padding,0,int(endX), currentFolderUIHeight);
        textAlign(CENTER, CENTER);
        // change working Directory Button
        newFolderButton();
        textFont(roboto);
    }

    /**
        @brief this is the UI element for opening a new folder at the top bar
    */
    void newFolderButton(){
        String newFolder = "new project";
        int rounded = 5;
        textSize(14);
        if(overButton(int(endX - textWidth(newFolder) - 6), 0, -1, int(textWidth(newFolder) + 6 + 24), 24 )){
            fill(colorTheme.primaryText);
            currentButton = "new project";
            currentButtonX = int(endX - textWidth(newFolder) - 6);
            currentButtonY = 0;
            currentButtonWidth = int(textWidth(newFolder) + 6);
            currentButtonHeight = textHeight;
            noStroke();
            rect(endX - textWidth(newFolder) - 6 - padding, (textHeight/ 4) + padding / 3, textWidth(newFolder) + 6,textHeight, rounded, rounded, rounded, rounded);
            textAlign(CENTER, CENTER);
            fill(colorTheme.linkColor);
            text(newFolder, endX - textWidth(newFolder) - 6 - padding, (textHeight / 6) + padding/3, textWidth(newFolder) + 6, textHeight);
        //make a white plus sign that follows the text;
        }else {
            fill(colorTheme.linkColor);
            textAlign(CENTER, CENTER);
            noStroke();
            rect(endX - textWidth(newFolder) - 6 - padding, (textHeight/ 4) + padding / 3, textWidth(newFolder) + 6,textHeight, rounded, rounded, rounded, rounded);
            fill(colorTheme.primaryText);
            text(newFolder, endX - textWidth(newFolder) - 6 - padding, (textHeight / 6) + padding / 3, textWidth(newFolder) + 6, textHeight);
        //make a white plus sign that follows the text;
        }
        
    }

    /**
        @brief UI element to make a single fileCard that store the contents of a file
    */
    void fileCard(File filePath, int startY) {
        String label = textChop(filePath.getName(), int(endX));
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

        
        
        if(currentFile == filePath){
            fill(colorTheme.calloutBackground);
        }
        
        
        
        rect(0,startY, int(endX), 24);
        fill(255);
        textSize(14);
        textAlign(LEFT, CENTER);
        text(label,12, startY, int(endX), 25);
    }

    /**
        @brief helper function for text formatting if the file name is larger than 
               the file launcher width
        @param bigString this is the string to be shortened
    */
    String textChop(String bigString, int boxWidth){
        String smallString = bigString;
        String front = "", back = "";
        // need to determine half the width of available space
        int halfWidth = int(boxWidth - textWidth("...") - 24) / 2;
        int cutIndex = 0;
        int cutAmount = 0;

        if( textWidth(bigString) > boxWidth - 6){
            cutIndex = int(bigString.length() / 2);

            // create the beginning of the string
            for(int i = 0; i< bigString.length(); i++) {
                if(textWidth(front) < halfWidth){
                    front += bigString.charAt(i);
                }
            }


            for(int i = bigString.length() - 1; i >= 0; i--) {
                if(textWidth(back) < halfWidth) {
                    back = bigString.charAt(i) + back;
                }
            }
            smallString = front + "..." + back;
        }
        
        return smallString;
        
    }
    /**
        @brief this is the drawable function that will be the main file view
    */
    void scrollableList() {
        clip(0,currentFolderUIHeight,int(endX), int(endY) - currentFolderUIHeight);
        for (int i = 0; i< accessableFiles.length; i++) {
            fileCard(accessableFiles[i], currentFolderUIHeight + (i * textHeight) - int(scrollY));
        }
        noClip();
    }

    // setter function for accessableFiles
    void setAccessableFiles(File[] fileList){
        accessableFiles = fileList;
    }

    /**
        @brief main UI element that is show in the fileLauncher on start up

    */
    void selectFileButton(){
        int textBoxStart = int(centerX - (w - 12) / 2);
        int textLength = int(w - 24);
        int textHeight = 30;
        String label = "Start a new project...";
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

    /**
        @brief this is just a helper function to call the selectFolder function
               this can probably be cut out
    */
    void selectFunction(){
        selectFolder("Select a file or folder to visualize audio", "folderSelected");
    }

    
    /**
        @brief function to grab the contents of a directory
        @param folderPath This is the folder file from which to grab the files
    */
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
            //println(fileList);
            return fileList;
        }else {
            println("No accepted files found within specified folder");
            return new File[0];
        }
    }
    
    /**
        @brief this is the controll for the scroll input from the mouseWheel
        @param delta this is the count from the mouse event    
    */
    void scroll(float delta){
        // if mouse is within the fileLauncher View then allow manipulation of scrollY value
        if(mouseX >= startX && mouseX <= endX){
            if(mouseY >= 25 && mouseY <= endY){
                // array length * fileContainer height - the height of the screen
                float maxScroll = ((accessableFiles.length * 24) -(endY + currentFolderUIHeight));
                scrollY = constrain(scrollY + (delta * scrollRate), 0, maxScroll);
            }

        }
    }
}
