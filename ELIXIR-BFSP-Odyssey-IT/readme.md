# Galaxy integration of Odyssey

## Build docker container

```
docker build . -t 'shiny-odyssey'
docker run -p 3838:3838 shiny-odyssey
```

### Deploy

```
TODO
```

## Run Wrapper in Galaxy Locally

### Get Galaxy

```
cd ~/git
git clone -b release_25.0 https://github.com/galaxyproject/galaxy.git
```

### Add IT configs

```
GALAXY_PATH=~/git/galaxy 
mv $GALAXY_PATH/config/galaxy.yml.interactivetools $GALAXY_PATH/config/galaxy.yml
mv $GALAXY_PATH/config/job_conf.yml.interactivetools $GALAXY_PATH/config/job_conf.yml
mv $GALAXY_PATH/config/tool_conf.xml.sample $GALAXY_PATH/config/tool_conf.xml 
```

### Add IT to instance

```
# add to toolbox conf
sed -i '/<\/toolbox>/i \
  <section id="interactivetools" name="Interactive tools">\
    <tool file="interactive/interactivetool_odyssey.xml" />\
  </section>' $GALAXY_PATH/config/tool_conf.xml 

# add the tool to the Galaxy instance (as symlink allows to further develop it, while Hot-Relode ;))
cd ELIXIR-BFSP-Odyssey-IT
ln -s $(pwd)/interactivetool_odyssey.xml $GALAXY_PATH/tools/interactive/interactivetool_odyssey.xml
```

### Run Galaxy and check if the tool works

```
cd $GALAXY_PATH
./run.sh
```