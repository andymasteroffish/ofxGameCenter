
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
    
    //set up the paramaters of your leaderboard
    leaderboardName = "YOUR_LEADERBOARD_ID";    //this must be the ID name of your leaderboard as you set it up in iTunes Connect
    friendsOnly = false;
    timeScope = SCORE_FOREVER;                  //you can also try out SCORE_WEEK and SCORE_TODAY
}

//--------------------------------------------------------------
void testApp::update(){

    //we don't want to load scores every frme, so I'm only sending this request if the leaderboard has no scores and is not loading any in
    //if you want to get a new list of scores, you will have to callretrieveTopScores again
    if (gameCenter.isAuthenticated && !gameCenter.getIsLoadingScores() && gameCenter.highScores.size()==0){
        int numToRetrieve = 20;     //how many scores to get. Must be at least 1
        int startPos = 1;           //where in the ranking to start. Must be at least 1
        
        //get the scores using the given parameters
        gameCenter.retrieveTopScores(leaderboardName, friendsOnly, timeScope, startPos, numToRetrieve);
        
        //you can also call retrieceTopScores with two more arguments
        //the first tells it whether or not to filter out Anonymous users. By default it is false
        //the second tells it whether or not to clear out the exiting list of scores. By default it is true
        //if you set this second argument to false, the new and old scores will be sorted by rank after being retrieved
        
        //this call would get the scores, without deleting the old ones, filtering out any anonymous users
        //gameCenter.retrieveTopScores(leaderboardName, friendsOnly, timeScope, startPos, numToRetrieve, true, false);
    }
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    ofPoint textStartPoint(15,25);
    ofSetColor(0);
    
    //if it has the scores, write them out
    if (gameCenter.highScores.size() > 0 && !gameCenter.getIsLoadingScores()){
        
        //print out what kind of scores these are
        ofDrawBitmapString(gameCenter.scoreScope + " - " + gameCenter.scoreTime, textStartPoint);
        
        float ySpacing=15;
        for (int i=0; i<gameCenter.highScores.size(); i++){
            Score thisScore = gameCenter.highScores[i];
            ofDrawBitmapString(ofToString(thisScore.rank)+ " - " + thisScore.name+" - "+ofToString(thisScore.score), textStartPoint.x, textStartPoint.y+ ySpacing*i + 30);
        }
        
    }
    
    //otherwise write out what state it's in
    if (gameCenter.getIsLoadingScores() == true){
        ofDrawBitmapString("LOADING SCORES..", textStartPoint);
        
    }
    if (gameCenter.getFailedToLoadScores() == true){
        ofDrawBitmapString("FAILED TO LOAD SCORES", textStartPoint);
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

