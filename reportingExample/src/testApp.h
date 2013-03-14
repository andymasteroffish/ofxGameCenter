#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxGameCenter.h"

class testApp : public ofxiPhoneApp{
	
public:
    void setup();
    void update();
    void draw();
    void exit();

    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);

    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    //reset game function will send the score to the high score list
    //as well as reporting the percentage complete of a total score achievement
    void resetGame();
    
    int totalScore;
    int score;

    ofxGameCenter gameCenter;
    
    string leaderboardName;         //ID name of your leaderboard for your app
    
    
    //some buttons to let us play the game
    float buttonSize;
    ofColor buttonUpCol, buttonDownCol;
    ofPoint pointButton, resetButton;
    bool pointButtonIsDown, resetButtonIsDown;
    
};


