<center>
[![tamp3](https://img.skitch.com/20120304-xkxqnuwucfe1fnu4bxmpj34tn5.jpg)](https://skitch.com/alagu/8g6rm/download.rb)
</center>

## Background

I usually download mp3 from Thiraipaadal and I go by picking up songs rather than whole movies. I suddenly remember a song which I've been humming and then I want to listen it. Youtube audio quality sucks. For Thiraipaadal, I have to search for a song, find it in Thiraipaadal, inspect the http request and download it.

I wanted it to be more easy. Like search in commandline and download right there. That is why I built this.


## Install

I've been using this in OS X, I am not sure how it works in other systems. It should work well in Ubuntu.

### Install

Requires [rvm](http://beginrescueend.com/rvm/install/), I'm using ruby-1.9.2-p290 (via .rvmrc). Once you have ruby and rvm,

    bundle install
    
This will install all the required gems. 


### Searching and Downloading

Once installed, you can search and download mp3s by song name

    ruby download.rb nilave
    
It also supports multi strings. You don't have to add quotes. It understands.

    ruby download.rb munbe va 
    

##  ♬

This was a post-dinner hack. I find myself listening to Ilayaraja songs. 

And yes, I did miss the New Year Ilayaraja concert.