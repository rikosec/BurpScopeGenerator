# BurpScopeGenerator

![Name](https://github.com/rikosec/BurpScopeGenerator/assets/67959612/851509e8-4b1b-4c42-ad4f-4459b9909553)


### This Script will help you to generate a perfect scope for Burpsuite Wildcard domains or https.

##### Follow below commands to clone the repository and run the script.

````bash
git clone https://github.com/rikosec/BurpScopeGenerator.git

chmod +x scopegen.sh

./scopegen.sh google.com -m wildcard # To generate Wildcard Scope
  
./scopegen.sh google.com -m https # To generate HTTPS Scope
  
./scopegen.sh -il domain.txt -m wildcard # To generate Wildcard Scope for List of Targets

./scopegen.sh -il domain.txt -m https # To generate HTTPS Scope for list of Targets

````
