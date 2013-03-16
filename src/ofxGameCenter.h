/***********************************************************************
 
 Copyright (C) 2013 by Andy Wallace
 
 This library was originally written for Worm Run, a game by Golden Ruby Games
 https://itunes.apple.com/app/id569497239?mt=8
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 ************************************************************************/

#ifndef andyMakes_GameCenter_h
#define andyMakes_GameCenter_h

#import <GameKit/GameKit.h>
#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxiPhoneExternalDisplay.h"

enum ScoreTimeScope { SCORE_TODAY=0, SCORE_WEEK, SCORE_FOREVER };

//score class used when retrieving highs cores from Game Center 
class Score{
public:
    string name;    //username
    int rank;       //rank in the retrieved leaderboard
    int score;      //actual score
    bool isFriend;  //is this player a friend of the user?
    
    void setup(string _name, int _rank, int _score, bool _isFriend){
        name=_name;
        rank=_rank;
        score=_score;
        isFriend = _isFriend;
    }
};

//achievement class used to store info for a single achievement
class Achievement{
public:
    string identifier;
    string name;
    string unachievedDescription;
    string achievedDescription;
    bool isComplete;
};



class ofxGameCenter{
public:
    
    //------------
    //basic info
    //------------
    void setup();
    void authenticateGameCenter();
    bool getIsAuthenticated();
    string getPlayerName();
    
    bool isAuthenticated;
    
    //------------
    //achievements
    //These functions return true if the achievement data was able to send
    //and false if it could not (such as if Game Center has not been authenticated)
    //------------
    bool reportGameCenterAchievement(float progress, string identifier);
    bool reportGameCenterAchievement(string identifier);
    
    //retrieving achievements
    bool getIsLoadingAchievements();
    void populateAchievements();            //fills the achievements vector with alla chievements asociated with your game
    void getCompletedAchievements();       //gets which achievements the player has earned. Called automaticly when popuateAchievements finishes
    void markAchievementComplete(string identifier);    //sets complete to be true for the given achievement
    
    bool isLoadingAchievements;
    vector<Achievement> achievements;
    
    //------------
    //high scores - leaderboards
    //------------
    void reportScore(int score, string leaderBoardName);
    void retrieveTopScores(string leaderBoardName, bool showingFriendsOnly, ScoreTimeScope timeScope, int startPos, int maxScoresToGet, bool filterAnonymous=false, bool clearScores=true);
    int getLocalPlayerRank();   //gets the player's position in the last leaderboard specified by retrieveTopScores
    bool getIsLoadingScores();
    bool getFailedToLoadScores();
    
    static bool sortHighScores(const Score &a, const Score &b);
    
    vector <Score> highScores;
    int localPlayerRank;    //player's rank in the most recently pulled leaderboard
    
    //loading
    bool isLoadingScores;         //flag to mark that a score request has been made, but is not finished yet
    bool failedToLoadScores;    //let's us know if the score request failed
    
    //catagorizing - this is just for display
    string scoreScope;  //friends or global
    string scoreTime;   //this week, this month etc.
    
    //-----------
    //Other
    //-----------
    void showGameCenter();  //this is a pretty crappy way of openning Game Center
    
};

#endif
