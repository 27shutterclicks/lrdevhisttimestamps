# Lightroom Develop History Steps Timestamps

An Adobe Lightroom Classic plugin that queries the Lightroom catalog (.lrcat file) and displays date and time information for an image's develop history steps or edit time.

![Plugin screenshot](/DevelopHistoryTimestamps.lrplugin/docs/lr_history_timestamps.jpg)


- [Introduction](#introduction)
- [Download](#download)
- [Installation](#installation)
- [Usage & Features](#usage--features)
- [Known Issues](#known-issues)

## Introductionl

Ever wished you could see when a certain develop history step was performed on a photo? It is now possible using this plugin for Lightroom Classic.

Example uses:

- Distinguish older develop edits from most recent ones (e.g.: when making changes to an older edited image and wanting to revert to how it was before making the recent edits).
- Establish the order of edits among multiple similar images or virtual copies, especially when settings are copied/pasted from one copy to another.
- Distinguish between latest metadata changes and latest develop edits.
- Identify develop edits made in a different timezone.

Lightroom Classic maintains timestamps for every develop history step, as well as a separate counter and timestamp for all other metadata changes. Strangely, this information is hidden and inaccessible to the user.

For Develop History steps, each step has a timestamp associated with it in the catalog, but these timestamps are only displayed in the History panel for specific steps or actions: Import, Export, Print and Edited in external app (like Photoshop). All other steps do not show a timestamp ever.

For metadata changes (flagging, rating, keywording, etc.), Lightroom maintains a separate counter that gets increased and timestamped with any changes in an image's metadata, including any develop module changes. This counter is used when sorting images by "Edit Time", but there is no way to see the actual date/time information anywhere. So you can know which image was last edited, but not WHEN. This plugin's View Last Edit time feature addresses that.

A discussion on the need for seeing the timestamps exists in the Adobe Community forums: [Timestamp in LR history for every command](https://community.adobe.com/t5/lightroom-ecosystem-cloud-based-discussions/timestamp-in-lr-history-for-every-command/td-p/11500328).


## Download

You may download the latest commit above as a zip file or [get the latest release](https://github.com/27shutterclicks/lrdevhisttimestamps/releases/latest).

## Installation

- Download the [latest release](https://github.com/27shutterclicks/lrdevhisttimestamps/releases/latest) zip archive from Github and extract to a folder of your choice.
- Copy the entire *DevelopHistoryTimestamps.lrplugin* folder to wherever you store your Lightroom plugins. A good location is  in a "*Lightroom Plugins*" folder where the Lightroom catalog file is located. 
- In Ligthroom, go to *File > Plug-in Manager* and click **Add**.
- Select the *DevelopHistoryTimestamps.lrplugin* folder u copied, then click **Select Folder** button.

## Usage & Features

The plugin adds three new options to File > Plug-in Extras and Library > Plug-in Extras:

- View Develop History Timestamps
- View Last Develop Time
- View Edit Time

To use, select a photo and then choose one of options above from File > Plug-in Extras (works from either Library or Develop module), or from Library > Plug-in Extras while in Library module or Loupe view.

### View Develop History Timestamps
*File > Plug-in Extras > View Develop History Timestamps* retrieves the date and time of all Develop History steps of an image in a floating window.

These are the same steps displayed in the Develop Module > History panel for any given image, with the addition of their respective timestamp at the end.

In addition to the all the timestamped history steps, the window will also show the total number of steps, the timestamp of when a file was first imported or first created for virtual copies (first history step) and when it was last edited in the Develop module (timestamp of the most recent history step). This is simply for convenience.

You may open multiple Develop History Steps windows by leaving the window open and getting the timestamps for other images.

For images that have numerous history steps (some can reach hundreds of steps), only the most recent 50 steps will be visible. To see the rest, click inside the window and drag down to see all entries or click inside the window and use Ctrl/Cmd + A to select all for copying and pasting elsewhere.

### View Last Develop Time
*File > Plug-in Extras > View Last Develop Time* retrieves the date and time of the last Develop History step of an image (also shown using the View Develop History Timestamps option). This is different from Lightroom's regular Edit Time timestamp, which also accounts for any changes to an image in regards to flagging, star rating, color labeling, keywording and maybe other metadata. 

Using this option can be useful when working with older images which may have been "developed" at a certain time, but managed (flagged, rated, labeled, keyworded) at a very different time. 

For example:

1. You visited Death Valley in March of 2016 to photograph the wild flowers super-bloom.
2. You processed your images in April 2016 and shared them all over social media. Your mom liked them all.
3. A few years passed while you photographed other things in other places.
4. The pandemic striked and there's nowhere to go. You stayed home and decided to look back on your Death Valley Wild Flowers Super-Bloom 2016 images and tackle the daunting task of keywording them. 
5. You did so exceptionally well, but then realized that now your reverse sorting by "Edit Time" didn't mean anything anymore, because the keywording affected the "edit" time.
6. You wondered if there's any way to find out when you last made develop changes to an image, since the last develop history step of "Saturation +65" lacks a date next to it. 

### View Edit Time
*File > Plug-in Extras > View Edit Time* retrieves the date and time of Lightroom's regular Edit Time timestamp, which is used behind the scenes to sort images in the Library module (or filmstrip) by "Edit Time", but is not shown anywhere.

The Edit Time is maintained by Lightroom separately from the develop history steps and is updated automatically with any changes to an image in regards to flagging, star rating, color labeling, keywording and maybe other metadata, including any develop module edits to the image. 

Using this option can be useful when you want to know the date and time when ANY change was made to an image, not just develop module changes.


## Known Issues

- Opening multiple floating windows works best on setups with multiple screens.
- On single screen setups in Windows, the floating window may stay hidden behind the main Lightroom window once it loses focus. This most commonly happens when the image is opened in the Develop module. To fix this:

1. Press "E" in Lightroom to switch to Library module.
2. (or) Try double clicking the window in your taskbar.
