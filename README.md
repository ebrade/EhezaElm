# EHeza Elm Challenge
This program Fetch Stories content IDs on the [HackerNews Top Stories API](https://hacker-news.firebaseio.com/v0/topstories.json)

After Fectching IDs it fetch their stories from https://hacker-news.firebaseio.com/v0/item/{StoryID}.json


## Elm version 

  - This program uses Elm 0.19.1 version
  - To install it uses: 
  ```sh
$ npm install create-elm-app -g
```
## Run This Program on Your Local Machine
To run this program 
1. Clone this repo 
```sh
$ git clone  https://github.com/ebrade/EhezaElm.git
```
2. Go to the root folder and Run the Program using below commands
```sh
$ cd EhezaElm
$ elm-app start
```
# View The program in the Browser
After starting the app the following links will show up
 -  Local: http://localhost:3000/ or 
 - On Your Network:  http://192.168.56.1:3000/

Network IP address may be different with yours.

# View Hacker News Top Stories
After visiting above link in a browser click on 
```sh 
Click on Fetch data from the browser
```
If all IDs are valid A list of the Stories will be displayed on the Browser.


