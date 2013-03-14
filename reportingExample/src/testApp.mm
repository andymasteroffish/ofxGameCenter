
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
 
 This example shows sending high scores as well as reporting achievements.
 
 Most of the GC stuff happens in resetGame()
 
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
    
    score = 0;
    totalScore = 0;
    
    //set up the paramaters of your leaderboard
    leaderboardName = "TopScoreAllTime";    //this must be the ID name of your leaderboard as you set it up in iTunes Connect
    
    //setup our butons
    buttonSize = 70;
    buttonUpCol = ofColor::yellow;
    buttonDownCol = ofColor::red;
    pointButton.set(80, 300);
    resetButton.set(ofGetWidth()-80, 300);
    pointButtonIsDown = false;
    resetButtonIsDown = false;
    
}

//--------------------------------------------------------------
void testApp::update(){

    
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    ofPoint textStartPoint(15,25);
    ofSetColor(0);
    
    
    //show the state of game center
    if (gameCenter.getIsAuthenticated() == false){
        ofDrawBitmapString("NOT AUTHENTICATED", textStartPoint);
    }else{
        ofDrawBitmapString("GAME CENTER AUTHENTICATED", textStartPoint);
        
    }
    
    //show the score
    string scoreText = "SCORE: "+ofToString(score)+"\nTOTAL: "+ofToString(totalScore);
    ofDrawBitmapString(scoreText, textStartPoint.x, textStartPoint.y+100);
    
    
    //draw the buttons
    
    //point button
    if (pointButtonIsDown)  ofSetColor(buttonDownCol);
    else                    ofSetColor(buttonUpCol);
    ofCircle(pointButton, buttonSize);
    
    //reset button
    if (resetButtonIsDown)  ofSetColor(buttonDownCol);
    else                    ofSetColor(buttonUpCol);
    ofCircle(resetButton, buttonSize);
    
    //lables
    ofSetColor(0);
    ofDrawBitmapString("GET A POINT", pointButton.x-45, pointButton.y+8);
	ofDrawBitmapString("RESET", resetButton.x-20, resetButton.y+8);
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){

    //see if this is in one of our buttons
    pointButtonIsDown = ofDist(pointButton.x, pointButton.y, touch.x, touch.y) < buttonSize;
    resetButtonIsDown = ofDist(resetButton.x, resetButton.y, touch.x, touch.y) < buttonSize;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    //see if this is in one of our buttons
    pointButtonIsDown = ofDist(pointButton.x, pointButton.y, touch.x, touch.y) < buttonSize;
    resetButtonIsDown = ofDist(resetButton.x, resetButton.y, touch.x, touch.y) < buttonSize;
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
    //check point button
    if ( ofDist(pointButton.x, pointButton.y, touch.x, touch.y) < buttonSize ){
        score++;
    }
    
    //check reset button
    if ( ofDist(resetButton.x, resetButton.y, touch.x, touch.y) < buttonSize){
        resetGame();
    }
    
    //set our buttons as up
    pointButtonIsDown = false;
    resetButtonIsDown = false;
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

//--------------------------------------------------------------
void testApp::resetGame(){
    
    //keep track of the total score
    totalScore += score;
    
    //report this score to the leaderboard
    gameCenter.reportScore(score, leaderboardName);
    
    
    //send the total score for the achievement
    int numNeeded = 40;     //I'm selecting an arbitrary number for sake of example
    //you can report achievements as a percentage complete so they will show up as partially completed in Game Center
    //the range is from 0 to 100, not 0.0 to 1.0
    float prc = ( (float)totalScore/(float)numNeeded )*100;
    //the report achievement funciton will return false if GC has not been authenticated yet
    gameCenter.reportGameCenterAchievement(prc, "25bounces");
    //nothing will appear on screen if a percentage of less than 100 is reported

    
    //reset the score
    score = 0;
    
}

