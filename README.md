# README

Video archive with ability to put a watermark. Uploaded video converted
to HTML5-supported formats (MP4, WEBM and OGG) and played using HTML5 player.

## Example

http://videodrome.atlantor.ru/

## Getting started

Videodrome requires Rails 5, Redis, ffmpeg and imagemagick.

1. Install ruby 2.2.2+ with bundler.

2. Install required system tools. For Debian/Ubuntu you can execute:
    ```
    sudo apt-get install ffmpeg imagemagick libmagickcore-dev libmagickwand-dev redis-server
    sudo apt-get install ffmpeg2theora # optional, for OGG format

    ```

3. Install required gems and prepare project:
    ```
    # goto app directory...
    bundle install
    rake db:migrate
    ```

4. Run Rails server and Sidekiq job processor (in separated terminals):
    ```
    rails s
    ...
    sidekiq
    ```

5. Open site in browser http://localhost:3000

## TODO list:

1. Protect original video file from downloading (store outside of public folder)

2. Clear previous generated video files after watermark changes

3. Add tests