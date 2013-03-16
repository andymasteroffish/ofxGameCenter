
/**************************************************************
 
 To use Game Center, you must have an application registered on iTunes Connect with Game Center setup
 Check Apple's guide for how to do that: 
 http://developer.apple.com/library/mac/#documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/15_GameCenter/GameCenter.html
 
 This will also require you to make a provisioning profile for the app
 The bundle identifier for your project will have to match the bundle identifier of your app on iTunes Connect
 you can change the bundle identifier in your project settings under info in your target
 
 You will need to include GameKit.framework in your project as well.
 To do this, go to your project settings, and in build phases of your target, open Link With Binary Libraries
 Click "+" and select GameKit.framework from the list
 
 If you're having trouble I can be reached 
 by email at andy@andymakes.com
 or on the openFrameworks forums as andyMakes
 
 **************************************************************/
 


#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	
	ofBackground(127,127,127);
    
    //setup gameCenter and have it send a request to Apple. You want to do this early in your app as it may take a little while to take effect
    gameCenter.setup();
    gameCenter.authenticateGameCenter();
    
}

//--------------------------------------------------------------
void testApp::update(){

    //we don't want to load scores every frme, so I'm only sending this request if the leaderboard has no scores and is not loading any in
    //if you want to get a new list of scores, you will have to callretrieveTopScores again
    if (gameCenter.isAuthenticated && !gameCenter.getIsLoadingAchievements() && gameCenter.achievements.size()==0){
        gameCenter.populateAchievements();
    }
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    ofPoint textStartPoint(15,15);
    ofSetColor(0);
    
    //if it has the achievements, write them out
    //cout<<"numachieves "+gameCenter.achievements.size()<<endl;
    if (gameCenter.achievements.size() > 0 && !gameCenter.getIsLoadingAchievements()){
        float ySpacing=35;
        for (int i=0; i<gameCenter.achievements.size(); i++){
            Achievement thisAchievement = gameCenter.achievements[i];
            
            //print the name and if they got it or not
            string text = thisAchievement.name+" - " + (thisAchievement.isComplete ? "COMPLETE" : "INCOMPLETE");
            //under that, put the description, using the achieved or achieved version depending on if they earned it
            if (thisAchievement.isComplete){
                text+= "\n"+thisAchievement.achievedDescription;
            }else{
                 text+= "\n"+thisAchievement.unachievedDescription;
            }
            ofDrawBitmapString(text, textStartPoint.x, textStartPoint.y+ ySpacing*i + 30);
        }
        
    }
    
    //otherwise write out what state it's in
    if (gameCenter.getIsLoadingAchievements() == true){
        ofDrawBitmapString("LOADING ACHIEVEMENTS..", textStartPoint);
    }
    if (gameCenter.getIsAuthenticated() == false){
        ofDrawBitmapString("NOT AUTHENTICATED", textStartPoint);
    }
	
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}

