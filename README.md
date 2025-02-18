# 7Summits IP, or "Peak Basecamp"
This is a POC of a new way to store, manage, and track changes to our shared code.

## Documentation
* [7Summits IP Fact Sheet](https://hive.7summitsinc.com/docs/DOC-45162)
* [Components & Dependencies (Developer Guide)](https://hive.7summitsinc.com/docs/DOC-45162) - view the Metadata link for each item
* [Git Flow Standards & Review Process](https://hive.7summitsinc.com/docs/DOC-44538)
* [Lightning Component Development Standards](https://hive.7summitsinc.com/docs/DOC-44537)

# Development Guide (WIP)

## Contributing
git flow! components with reuse-potential should start here!

## Starting Client Projects
fork!

## File Structure
- `src/aura` contains all lightning components.
- `styles/components/{LightningComponent}/{LightningComponent}.less` are files specific to each lightning component. Running gulp will compile these and put them in the appropriate lightning component bundle.
    - Ensure that `{LightningComponent}` is replaced to match the name of the aura bundle.
- `styles/overrides/` contains modular less files that overwrite styles of OTB salesforce components and managed components, organized per component in `/salesforce/` and `/components/`, respectively.
    - These compile to `/src/staticresource/peakLightning/styles/overrides.css`
- `scripts/components/{LightningComponent}/{LightningComponentController or LightningComponentHelper}.js` are javascript files specific to each lightning component. Running gulp will compile these using [Babel, transpiling es2015 javascipt into es5 compatible code](https://babeljs.io/docs/plugins/preset-es2015/) and put them in the appropriate lightning component bundle.
    - Ensure that `{LightningComponentController or LightningComponentHelper}.js` is replaced to match the name of the aura bundle and JS file in the bundle you are targeting.
- `scripts/global/` contains global JavaScript that affects more than one component and/or cannot be contained in a single lightning component.
    - These compile to `/src/staticresource/peakLightning/scripts/peakLightning.js`
- `peakLightning.zip` is a seed for the static resource that will contain the community's assets, like fonts, images, override styles and global JavaScript.

##Local Setup
To avoid potential issues, make sure to follow the order prescribed here! Please feel free to modify this readme for clarity as needed.

###0. Recommended IntelliJ Settings
Preferences > Languages & Frameworks > Illuminated Cloud > Validation & Deployment
**Check:**
* Deploy on save
* Deploy on external change
* Deploy static resource bundle on contents change
**Uncheck:**
* Use separate source root for static resource bundles

Preferences > Appearance & Behavior > System Settings
**Uncheck:**
* Synchronize files on frame or editor tab activation
* Save files on frame deactivation
* Save files automatically if application is idle

###1. IntelliJ & Git
1. Create a new Illuminated Cloud project using your Salesforce credentials. Do not modify the subscription yet or create any new components.
1. From your local copy of this repository, copy over `/styles/`, `/scripts/`, `gulpfile.js`, `package.json`, `peakLightning.zip` into the directory created by IntelliJ.
1. Initiate a new git repository from the project directory called `{client}-lightning`.
1. Make sure to create a readme.md file to store any project-specific development notes.

###2. Salesforce
1. Locally, rename `peakLightning.zip` to match your community's namespace.
1. In Salesforce Setup, create a new static resource that matches your community's namespace and upload the renamed `peakLightning.zip`. 
1. Install Peak Components as a package by using the install link here: https://hive.7summitsinc.com/docs/DOC-41155

###3. Back to IntelliJ
1. **IntelliJ IDEA > Preferences > System Settings** - Make sure "Synchronize files on frame or editor tab activation" is unchecked.
1. **IntelliJ IDEA > Preferences > Languages & Frameworks > Illuminated Cloud** - Make sure "Use separate source root for static resource bundles" is unchecked.
1. Right click on `/src/` and select **Illuminated Cloud > Configure Module**.
    - Make sure your subscription is set to `Selected` and click the blue arrows to refresh the list. Select the following metadata types: `ApexClass`, `AuraDefinitionBundle`, `StaticResource`, `CustomLabel`, `CustomObject`. To keep things clean, it's recommended that you only select metadata that 7S has created and/or needs to modify. Apply and click "OK".
1. Right click on `/src/` and select **Illuminated Cloud > Retrieve Metadata**. This option will only pull down metadata that you were not subscribed to before.
1. Right click on `/src/` and select **Illuminated Cloud > Refresh Metadata**. This option will refresh metadata that you have locally.
1. Navigate to `/src/staticresources/peakLighting.resource` and right click on it. Select **Illuminated Cloud > Convert to Static Resource Bundle** to expand the compressed resource and interact with it as a directory.

###4. Gulp
1. Open package.json and replace the values of `name`, `namespace`, and `description` to match your community.
    - `name` should use underscores instead of spaces.
    - `namespace` should be camelCase, as it is used for the community's static resource.
1. `~npm install` to install dependencies.
1. `~gulp` to watch and compile component styles, override styles, and JavaScript.

## Pushing to Environments
### Ant Build
* Setup > Communities > Enable Communities
* Users > Select your user (installing user) and make sure to assign a Role
### Deploying with IntelliJ"# towson-lightning" 
