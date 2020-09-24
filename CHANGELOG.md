# Change Log

### 4.17.1.0

- Add Chromium `browser` widget SWT JAR file to support `:chromium` style (e.g. `browser(:chromium)`) when the binaries are present.
- Designate gem as a 'java' platform gem (i.e. jruby)

### 4.17.0.0

- Upgrade to SWT (Standard Widget Toolkit) 4.17 and sync version with SWT going forward
- Upgrade to Glimmer (DSL Engine) 1.0.0
- Sync version number with the SWT version number (first two numbers, leaving the last two as minor and patch)

### 0.6.9

- Log error messages when running inside sync_exec or async_exec (since you cannot rescue their errors from outside them)
- Exclude gladiator from required libraries during sample listing/running/code-display
- Ensured creating a widget with swt_widget keyword arg doesn't retrigger initializers on its parents if already initialized
- Extract `WidgetProxy#interpret_style` to make it possible to extend with further styles with less code (e.g. CDateTimeProxy adds CDT styles by overriding method)

### 0.6.8

- Support external configuration of `WidgetProxy::KEYWORD_ALIASES` (e.g. `radio` is an alias for `button(:radio)`)
- Support external configuration of `Glimmer::Config::SAMPLE_DIRECTORIES` for the `glimmer sample` commands from Glimmer gems

### 0.6.7

- Fix issue with re-initializing layout for already initialized swt_widget being wrapped by WidgetProxy via swt_widget keyword args
- Change naming of scaffolded app bundle for mac to start with a capital letter (e.g. com.evernote.Evernote not com.evernote.evernote)

### 0.6.6

- Add User Profile sample from DZone article
- Colored Ruby syntax highlighting for sample:code and sample:run tasks courtesy of tty-markdown
- Support `check` as alias to `checkbox` DSL keyword for Button widget with :check style. 
- Validate scaffolded custom shell gem name to ensure it doesn't clash with a built in Ruby method
- GLIMMER_LOGGER_ASYNC env var for disabling async logging when needed for immediate troubleshooting purposes
- Fix issue with table equivalent sort edge case (that is two sorts that are equivalent causing an infinite loop of resorting since the table is not correctly identified as sorted already)

### 0.6.5

- Added the [rake-tui](https://github.com/AndyObtiva/rake-tui) gem as a productivity tool for arrow key navigation/text-filtering/quick-triggering of rake tasks
- Use rake-tui gem in `glimmer` command by default on Mac and Linux

### 0.6.4

- Display glimmer-dsl-swt gem version in glimmer command usage
- Include Glimmer Samples in Gem and provide access via `glimmer samples:list`, `glimmer samples:run`, and `glimmer samples:code` commands
- Fix issue with glimmer not listing commands in usage without having a Rakefile
- Fix issue with passing --log-level or --debug to the `girb` command

### 0.6.3

**Scaffolding:**

- Add mnemonic to Preferences menu in scaffolding
- Make bin/glimmer, bin/girb, and scaffolded bin/script files call jruby instead of ruby in the shebang
- Launch scaffolded app on Linux without using packaging (via `glimmer bin/app_script`)
- Add all of Mac, Windows, and Linux icons upon scaffolding (not just for the OS we are on)

**Packaging:**

- Perform gemspec:generate first during packaging
- Ensure lock_jars step happens before package:jar to have vendor jar-dependencies packaged inside JAR file
- Change lock_jar vendor-dir to vendor/jars and add it to .gitignore
- Handle naming of -Bwin.menuGroup properly for Windows in scaffolded custom shell gems (and apps) (e.g. instead of Glimmer Cs Timer set to Timer only or namespace when available in a CustomShell)
- Support passing javapackager extra args after `glimmer package:native` command inside double-quotes (e.g. `glimmer package:native "-title 'CarMaker'"`)
- JDK14 experimental `jpackage` support as a packaging alternative to `javapackager` (Not recommended for production use and must specify JDK8 as JRE with an additional option since SWT doesn't support JDK14 yet)

**GUI:**

- Add radio and checkbox table editors
- Add `content` method to DisplayProxy
- Add `content` method to MessageBox
- WidgetProxy now supports taking a fully constructed swt_widget argument instead of init_args

**CI:**

- Add Windows to Travis-CI

**Issues:**

- Fix issue with TableProxy editor rejecting false and nil values set on items
- Fix issue with message_box getting stuck upon closing when no parent in its args
- Fix transient issue with git bash not interpretting glimmer package[msi] as a rake task (yet as packages instead as it resolves [msi] by picking s to match packages local directory)
- Fix issue with getting "Namespace is required!" when running `glimmer scaffold[app_name]` or `glimmer scaffold:gem:customshell[name,namespace]` (https://github.com/AndyObtiva/glimmer/issues/5)

### 0.6.2

- Set default margins on layouts (FilLayout, RowLayout, GridLayout, and any layout that responds to marginWidth and marginHeight)
- Have scrolled_composite autoset min width and min height based on parent size
- Add `radio`, `toggle`, `checkbox`, and `arrow` widgets as shortcuts to `button` widget with different styles
- Add parent_proxy method to WidgetProxy
- Add post_add_content hook method to WidgetProxy
- Add `image` keyword to create an ImageProxy and be able to scale it
- Fix issue with ImageProxy not being scalable before swt_image is called

### 0.6.1

- Lock JARs task for jar-dependencies as part of packaging
- Add 'vendor' to require_paths for custom shell gem
- Add Windows icon to scaffold
- Generate scaffolded app/custom-shell-gem gemspec as part of packaging (useful for jar-dependencies)
- Support a package:native type option for specifying native type
- Add a preferences menu for Windows (since it does not have one out of the box)
- Fix app scaffold on Windows by having it generate jeweler gem first (to have gemspec for jar-dependencies)
- Fix girb for Windows

### 0.6.0

- Upgrade to JRuby 9.2.13.0
- Upgrade to SWT 4.16
- Support `font` keyword
- Support cursor setting via SWT style symbols directly
- Support `cursor` keyword

### 0.5.6

- Fixed issue with excluding on_swt_* listeners from Glimmer DSL engine processing in CustomWidget
- Add shell minimum_size to Tic Tac Toe sample for Linux

### 0.5.5

- Add 'package' directory to 'config/warble.rb' for packaging in JAR file
- Fix issue with image path conversion to imagedata on Mac vs Windows

### 0.5.4

- Fix issue with uri:classloader paths generated by JRuby when using File.expand_path inside packaged JAR files

### 0.5.3

- Set widget `image`/`images` property via string file path(s) just like `background_image`

### 0.5.2

- Added :full_selection to table widget default SWT styles

### 0.5.1

- Made packaging -BsystemWide option true on the Mac only

### 0.5.0

- Upgrade to glimmer 0.10.1 to take advantage of the new logging library
- Make Glimmer commands support acronym, dash and no separator (default) alternatives
- Support scaffold commands for gems with `scaffold:gem:cw` pattern (`cs` as other suffix)
- Support listing commands with `list:gems:cw` pattern (`cs` as other suffix)
- Add -BinstalldirChooser=true / -Bcopyright=string / -Bvendor=string / -Bwin.menuGroup=string to Package class to support Windows packaging
- Configure 'logging' gem to generate log files on Windows/Linux/Mac and syslog where available
- Configure 'logging' gem to do async buffered logging via a thread to avoid impacting app performance with logging
- Make GLIMMER_LOGGER_LEVEL env var work with logging gem
- Update all logger calls to be lazy blocks
- Add logging formatter (called layout in logging library)
- Support legacy rake tasks for package and scaffold (the ones without gem/gems nesting)
- GLIMMER_LOGGER_LEVEL env var disables async logging in logging gem to help with immediate troubleshooting
- Create 'log' directory if :file logging device is specified
- Remember log level when reseting logger after the first time
- Dispose all tree items when removed
- Dispose all table items when removed
- Remove table model collection observers when updating
- Make message_box instantiate a shell if none passed in
- Eliminate unimportant (false negative) log messages getting reported as ERROR when running test suite
- Sort table on every change to maintain its sort according to its sorted column

### 0.4.1

- Fixed an issue with async_exec and sync_exec keywords not working when used from a module that mixes Glimmer

### 0.4.0

- Support SWT listener events that take multiple-args (as in custom libraries like Nebula GanttChart)
- Drop on_event_* keywords in favor of on_swt_* for SWT constant events
- Remove Table#table_editor_text_proxy in favor of Table#table_editor_widget_proxy
- Set WidgetProxy/ShellProxy/DisplayProxy data('proxy') objects
- Set CustomWidget data('custom_widget') objects
- Set CustomShell data('custom_shell') objects
- Delegate all WidgetProxy/ShellProxy/DisplayProxy/CustomWidget/CustomShell methods to wrapped SWT object on method_missing

### 0.3.1

- Support multiple widgets for editing table items

## 0.3.0

- Update API for table column sorting to pass models not properties to sorting blocks
- Support table multi-column sort_property
- Support table additional_sort_properties array
- Display table column sorting direction sign
- Update Scaffold MessageBox reference to message_box DSL keyword
- Fix issue with different sorting blocks not reseting each other on different table columns

## 0.2.4

- Make table auto-sortable
- Configure custom sorters for table columns
- Support for ScrolledComposite smart default behavior (auto setting of content, h_scroll/v_scroll styles, and horizontal/vertical expand)

## 0.2.3

- Upgraded to Glimmer 0.9.4
- Add vendor directory to warble config for glimmer package command.
- Make WidgetProxy register only the nearest ancestor property observer, calling on_modify_text and on_widget_selected for widgets that support these listeners, or otherwise the widget specific customizations
- Add glimmer package:clean command
- Make scaffolding gems fail when no namespace is specified
- Add a hello menu samples

## 0.2.2

- Support Combo custom-text-entry data-binding
- Remove Gemfile.lock from .gitignore in scaffolding apps/gems

## 0.2.1

- Support latest JRuby 9.2.12.0
- Support extra args (other than style) in WidgetProxy just like ShellProxy
- Specify additional Java packages to import when including Glimmer via Glimmer::Config::import_swt_packages=(packages)
- Add compatibility for ActiveSupport (automatically call ActiveSupport::Dependencies.unhook! if ActiveSupport is loaded)
- Fix bug with table items data binding ignoring bind converters

## 0.2.0

- Simplified Drag and Drop API by being able to attach drag and drop event listener handlers directly on widgets
- Support drag and drop events implicitly on all widgets without explicit drag source and drop target declarations
- Set drag and drop transfer property to :text by default if not specified
- Automatically set `event.detail` inside `on_drag_enter` to match the first operation specified in `drop_target` (make sure it doesn't cause problems if source and target have differnet operations, denying drop gracefully)
- Support `dnd` keyword for easily setting `event.detail` (e.g. dnd(:drop_copy)) inside `on_drag_enter` (and consider supporting symbol directly as well)
- Support Drag and Drop on Custom Widgets
- Fix hello_computed.rb sample (convert camelcase to underscore case for layout data properties)

## 0.1.3

- Added 'org.eclipse.swt.dnd' to glimmer auto-included Java packages
- Updated Tic Tac Toe sample to use new `message_box` keyword 
- Add DragSource and DropTarget transfer expression that takes a symbol or symbol array representing one or more of the following: FileTransfer, HTMLTransfer, ImageTransfer, RTFTransfer, TextTransfer, URLTransfer
- Set default style DND::DROP_COPY in DragSource and DropTarget widgets
- Support Glimmer::SWT::DNDProxy for handling Drop & Drop styles
- Implemented list:* rake tasks for listing Glimmer custom widget gems, custom shell gems, and dsl gems
- Support querying for Glimmer gems (not just listing them)
- Fix bug with table edit remaining when sorting table or re-listing (in contact_manager.rb sample)
- Update icon of scaffolded apps to Glimmer logo

## 0.1.2

- Extracted common model data-binding classes into glimmer

## 0.1.1

- Fixed issue with packaging after generating gemspec
- Fixed issue with enabling development mode in glimmer command

## 0.1.0

- Extracted Glimmer DSL for SWT (glimmer-dsl-swt gem) from Glimmer
