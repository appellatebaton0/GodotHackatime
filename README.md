<a id="readme-top"></a>


<!-- HEADER -->
<br />
<div align="center">
    <h3 align="center"> Godot Hackatime </h3>
    <p align="center">
        A fork of <a href="https://github.com/BudzioT/Godot_Super-Wakatime">Godot Super Wakatime</a>, with bonus features, for Hackatime users to measure time spent in Godot
        <br />
        !! Not yet officially approved to use in events created by Hack Club - UNDER REVIEW
        <br />
        <br />
        <a href="https://github.com/appellatebaton0/GodotHackatime/issues/new">Report Bug / Request Feature</a>
    </p>
</div>

<!-- CONTENTS -->
<details>
    <summary>Table of Contents</summary>
    <ol>
        <li>
            <a href="#about">About The Project</a>
            <ul>
                <li><a href="#built-with">Built Using</a></li>
            </ul>
        </li>
        <li>
            <a href="#getting-started">Getting Started</a>
            <ul>
                <li><a href="#installation">Installation</a></li>
            </ul>
        </li>
        <li><a href="#usage">Usage</a></li>
        <li><a href="#license">License</a></li>
    </ol>
</details>


<!-- ABOUT -->
## About The Project
For more info on the base project, check the <a href="https://github.com/BudzioT/Godot_Super-Wakatime">original's</a> README. This is focused on what's new in relation to that.

This plugin improves upon a few of the base project's features, as well as adding some of its own. Namely;
<ul>
<li><details>
<summary>The dock that shows the time now has a full interface when clicked, instead of a blank panel. This dock contains;</summary>
    <ul>
    <li> Project Name -> What your project will show as in Hackatime
    <li>Streak -> How many days you've been working straight
    <li>Time Today -> How long you've spent coding in the past 24h
    <li>All Time -> How long you've spent on the current project overall.
    <li>Language Pie Chart / Box -> A pie chart showing how long you've spent per language, including Scene vs GDScript
        <ul><li> You can click the colors on the key in the bottom left to change its colors as you like. They'll be removed on reopening the project.
        </ul>
    <li>Goal Setting -> You can set a goal of a certain amount of hours by a date via the boxes in the top left.
        <ul>
        <li> The Hours box takes any float number.
        <li> The Date box takes an ISO-8601 datetime string, as per Godot's conventions - YYYY-MM-DDTHH:MM:SS (ex 2026-01-01T09:30:00)
        </ul>
    <li>Progress Bars -> Two progress bars showing how much time you've done towards your goal for the day, and in total.
</details>
<li> More accurate time display -> Shows the time for the current project (the base shows global day time)
<li> Offline tracking display -> Still shows the time spent while offline, though it may be less accurate.



</ul>

<!-- GETTING STARTED -->
## Getting Started
How to install and use this software? It's easy!

### Installation
1. Get the addon file either by cloning the repository, or downloading this project as a zip file;
    - Clone the repository -> Run in terminal:
        ```sh
        git clone https://github.com/appellatebaton0/GodotHackatime.git
        ```
    - Download as zip -> scroll to the top of the page, and click Code, then Download Zip.
2. Go into your project
3. Copy the `addons/godot-hackatime` folder into your project `res://addons` directory. 
    - If the `res://addons` directory doesn't exist, make it.

<p align="right">(<a href="#readme-top">top</a>)</p>

<!-- USAGE -->
## Usage
Don't know how to use this plugin? Here are the steps:
1. Turn on the plugin in your plugins. In your `Project -> Project Settings -> Plugins -> `Click the `Enable` checkbox near this plugin
2. If prompted for API key, provide it from Wakatime website
3. if there is an issue with it, please manually create `~/.wakatime.cfg` file with these contents:
    ```sh
    [settings]
    api_url = https://hackatime.hackclub.com/api/hackatime/v1
    api_key=xxxx
    ```
4. Wakatime CLI should have been installed automatically along with Ouch! Decompression library
5. Work on your project! You should see your results on Hackatime!
6. You can also see your time via the bottom dock in the editor.

<p align="right">(<a href="#readme-top">top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
