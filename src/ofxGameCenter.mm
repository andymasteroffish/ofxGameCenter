
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


#include "ofxGameCenter.h"

//--------------------------------------------------------------
void ofxGameCenter::setup(){
    isAuthenticated = false; 
    localPlayerRank = -1;   //essentialy returning an error if this number is requested before a score has been loaded
    failedToLoadScores = false;
    isLoadingScores = false;
    isLoadingAchievements = false;
}

//--------------------------------------------------------------
void ofxGameCenter::authenticateGameCenter() {
    cout<<"attempting to authenticate Game Center"<<endl;
    if(NSClassFromString(@"GKLocalPlayer") == nil) return;
    
    if([GKLocalPlayer localPlayer].authenticated){
        cout<<"Game Center already authenticated"<<endl;
        isAuthenticated = true;
        return;
    }
    
    cout<<"sending GC request..."<<endl;
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if([GKLocalPlayer localPlayer].authenticated) {
            cout << "GAME CENTER AUTHENTICATED" << endl;
            isAuthenticated = true; //mark that we have authenticated
        } else {
            // game center failed
            cout << "GAME CENTER AUTHENTICATE FAILED :" << endl;
            cout<<ofxNSStringToString(error.description)<<endl;
        }
    }];
    
}

//--------------------------------------------------------------
bool ofxGameCenter::getIsAuthenticated(){
    return isAuthenticated;
}

//--------------------------------------------------------------
void ofxGameCenter::reportScore(int score, string leaderBoardName){
    cout<<"sending score of: "<<score<<"  to leader board: "<<leaderBoardName<<endl;
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory: ofxStringToNSString(leaderBoardName)] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil){
            cout<<"ERROR REPORTING THE SCORE"<<endl;
        }else{
            cout<<"SUCCESS: score of "<<score<<" sent to "<<leaderBoardName<<endl;
        }
    }];
     
}

//--------------------------------------------------------------
//this function will fill the highscores vector with the scores returned form the given parameters.
//It does not return anything itself
void ofxGameCenter::retrieveTopScores(string leaderBoardName, bool showingFriendsOnly, ScoreTimeScope timeScope, int startPos, int maxScoresToGet, bool filterAnonymous, bool clearScores){
    if (!isAuthenticated){
        cout<<"GAME CENTER NOT AUTHENTICATED - CANNOT RETRIEVE SCORES"<<endl;
        return;
    }
    
    //make sure that start pos and maxScore to get are valid
    if (startPos<1){
        cout<<"START POS SHOULD NOT BE LESS THAN 1"<<endl;
    }
    if (maxScoresToGet<1){
        cout<<"MAX SCORES SHOULD NOT BE LESS THAN 1"<<endl;
    }
    
    cout<<"getting scores..."<<endl;
    if (clearScores)    highScores.clear();         //clear out the scores currently stored
    isLoadingScores=true;         //mark that we are waiting on scores
    failedToLoadScores=false;   //assume this will work
    
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    leaderboardRequest.category = ofxStringToNSString(leaderBoardName);
    
    if (leaderboardRequest != nil)
    {
        //set the ledader board request based on the values provided
        if (showingFriendsOnly){
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
            scoreScope="Friends' Scores";
        }
        else{
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
            scoreScope="Global Scores";
        }
        
        if (timeScope==SCORE_TODAY){
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
            scoreTime="Today";
        }
        else if (timeScope==SCORE_WEEK){
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
            scoreTime="This Week";
        }else{
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
            scoreTime="Of All Time";
        }
        
        //set how many scores to retrieve
        leaderboardRequest.range = NSMakeRange(startPos, maxScoresToGet);
        
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            //save this player's name
            //string isAuthenticated= ofxNSStringToString([[GKLocalPlayer localPlayer] alias]);
            
            if (error != nil)
            {
                // handle the error.
                cout<<"couldn't load the scores"<<endl;
                failedToLoadScores=true;
                isLoadingScores=false;
            }else{
                cout<<"no errors"<<endl;
            }
            if (scores != nil)
            {
                //there are scores to examine
                cout<<"scores found!"<<endl;
                
                //save the player's local rank
                localPlayerRank = [[leaderboardRequest localPlayerScore] rank];
                
                //get the player IDs
                NSMutableArray *playerIDs=[NSMutableArray arrayWithCapacity:10];
                for (int i=0; i<[scores count]; i++)
                    [playerIDs addObject:[[scores objectAtIndex:i] playerID]];
                
                //try to get the aliases (user names)
                [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error)
                 {
                     if (error != nil)
                     {
                         cout<<"Couldn't get the aliases"<<endl;
                         failedToLoadScores=true;
                         isLoadingScores=false;
                     }
                     if (players != nil)
                     {
                         //we've gotten all the info we need, now process it
                         
                         //mark if we'll need to sort these scores against what was alreayd in there
                         bool needToSort = false;
                         if (!clearScores && highScores.size()>0){
                             needToSort = true;
                         }
                         
                         //go through each score and add it to the vector
                         if (clearScores)   highScores.clear();
                         for(int i = 0; i<scores.count; i++){
                             string name= ofxNSStringToString([[players objectAtIndex:i]alias]);
                             bool isFriend = [[players objectAtIndex:i]isFriend] || (name==getPlayerName());
                             
                             Score newScore;
                             newScore.setup(name, ((GKScore*)[scores objectAtIndex:i]).rank, ((GKScore*)[scores objectAtIndex:i]).value, isFriend);
                             //cout<<"name: "<<newScore.name<<"   score: "<<newScore.score<<"   friend: "<<newScore.isFriend<<endl;
                             
                             //if we are filterring out anonymouse, make sure that there is a name there
                             if (!filterAnonymous || newScore.name!="Anonymous"){
                                 highScores.push_back(newScore);
                             }
                         }
                         
                         cout<<highScores.size()<<" scores retrieved!"<<endl;
                         
                         //call ofSort if there were scores alreayd in there
                         if (needToSort){
                             ofSort(highScores, ofxGameCenter::sortHighScores);
                         }
                         
                         failedToLoadScores=false;
                         isLoadingScores=false;
                         
                     }
                 }];
            }
            else{
                cout<<"no scores - the leaderboard is empty or something went wrong"<<endl;
                failedToLoadScores=true;
                isLoadingScores=false;
            }
        }];
    }
    else{
        cout<<"high scores came back nil."<<endl;
        failedToLoadScores=true;
        isLoadingScores=false;
    }
}

//--------------------------------------------------------------
bool ofxGameCenter::sortHighScores(const Score &a, const Score &b){
    return a.score > b.score;
}

//--------------------------------------------------------------
//returns the player's position on the last leaderboard grabbed from retrieveTopScores
//you must call retrieveTopScores before this function, and give it time to return the scores
int ofxGameCenter::getLocalPlayerRank(){
    if (localPlayerRank==-1){
        cout<<"NO SCORES RETRIEVED YET. RETURNING -1. CALL retrieveTopScores BEFORE USING THIS FUNCTION"<<endl;
    }
    
    return localPlayerRank;
}

//--------------------------------------------------------------
bool ofxGameCenter::getIsLoadingScores(){
    return isLoadingScores;
}
//--------------------------------------------------------------
bool ofxGameCenter::getFailedToLoadScores(){
    return failedToLoadScores;
}

//--------------------------------------------------------------
bool ofxGameCenter::reportGameCenterAchievement(float progress, string identifier) {
    if(NSClassFromString(@"GKLocalPlayer") == nil) return false;
    
    if(![GKLocalPlayer localPlayer].authenticated) return false;
    
    GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:[NSString stringWithCString:identifier.c_str() encoding:NSUTF8StringEncoding]];
    
    if(achievement) {
        if([achievement respondsToSelector:@selector(setShowsCompletionBanner:)]){
            [achievement setShowsCompletionBanner:YES];
        }
        
        [achievement setPercentComplete:progress];
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            // got achievement
            cout<<"SUCCESS: achievement "<<identifier<<" reported"<<endl;
        }];
    }
    
    return true;
}


//--------------------------------------------------------------
bool ofxGameCenter::reportGameCenterAchievement(string identifier) {
    return reportGameCenterAchievement(100, identifier);   //100 is percentage complete
}

//--------------------------------------------------------------
void ofxGameCenter::populateAchievements(){
    isLoadingAchievements = true;
    cout<<"populating achievements..."<<endl;
    //if this is the first call, populate the list of the achievements
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler: ^(NSArray *descriptions, NSError *error) {
        if (error != nil){
            cout<<"ERROR LOADING INFO"<<endl;
        }if (descriptions != nil){
            //clear out anything that might currently be in there
            achievements.clear();
            
            for (int i=0; i<[descriptions count]; i++){
                GKAchievementDescription *thisAchievement = [descriptions objectAtIndex:i];
                
                Achievement newAchievement;
                newAchievement.identifier = ofxNSStringToString([thisAchievement identifier]);
                newAchievement.name = ofxNSStringToString([thisAchievement title]);
                newAchievement.unachievedDescription = ofxNSStringToString([thisAchievement unachievedDescription]);
                newAchievement.achievedDescription = ofxNSStringToString([thisAchievement achievedDescription]);
                newAchievement.isComplete = false;
                
                //add it to the vector
                achievements.push_back(newAchievement);
            }
            
            isLoadingAchievements = false;
            
            //now that we have all of the names, let's see which ones the player earned
            getCompletedAchievements();
        }
    }];
    
}
//--------------------------------------------------------------
void ofxGameCenter::getCompletedAchievements(){
    isLoadingAchievements = true;
    cout<<"getting completed achievements..."<<endl;
    
    //load in a list of all of the completed achievements
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil)
        {
            cout<<"ERROR RETRIEVING ACHIEVEMENTS"<<endl;
        }
        else
        {
            isLoadingAchievements = false;
        }
        
        if (achievements != nil)
        {
            cout<<"COMPLETED"<<endl;
            for (int i=0; i<[achievements count]; i++) {
                GKAchievement *thisAchievement = [achievements objectAtIndex:i];
                
                markAchievementComplete(ofxNSStringToString([thisAchievement identifier]));
                
            }
            
            isLoadingAchievements = false;
        }
        
    }];
    
}

//--------------------------------------------------------------
void ofxGameCenter::markAchievementComplete(string identifier){
    //go through the vector and find this identifier
    for (int i=0; i<achievements.size(); i++){
        if (achievements[i].identifier == identifier){
            //mark it as complete
            achievements[i].isComplete = true;
            
            return;
        }
    }
    
    cout<<"Couldn't find the achievement identifier: "<<identifier<<endl;
}

//--------------------------------------------------------------
bool ofxGameCenter::getIsLoadingAchievements(){
    return isLoadingAchievements;
}

//--------------------------------------------------------------
string ofxGameCenter::getPlayerName(){
    if (!isAuthenticated){
        cout<<"GAME CENTER NOT AUTHENTICATED - CANNOT GET NAME"<<endl;
        return "";
    }
    
    return ofxNSStringToString([[GKLocalPlayer localPlayer] alias]);
}

//--------------------------------------------------------------
//This is not a propper display. It just opens the Game Center app.
//Use at your own discretion
void ofxGameCenter::showGameCenter(){
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:/games"]];
}

