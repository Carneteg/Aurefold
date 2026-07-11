<?php
# EMBERWOLD — extension & theme configuration.
# Include from the generated LocalSettings.php by adding at the very end:
#   require_once "$IP/LocalSettings.emberwold.php";

## Site identity
$wgSitename = "Emberwold";
$wgMetaNamespace = "Emberwold";
$wgLogos = [
    '1x' => "$wgResourceBasePath/resources/assets/emberwold_logo.png",
    'icon' => "$wgResourceBasePath/resources/assets/emberwold_logo.png",
];

## Skin: Vector 2022 (bundled). The ember theme lives in MediaWiki:Common.css.
$wgDefaultSkin = 'vector-2022';

## Extensions (all bundled with the MediaWiki tarball/image — nothing to download)
wfLoadExtension( 'ParserFunctions' );       # {{#if:}} etc. for infoboxes
$wgPFEnableStringFunctions = true;
wfLoadExtension( 'Scribunto' );             # Lua for advanced templates
$wgScribuntoDefaultEngine = 'luastandalone';
# TemplateStyles is NOT bundled in the Docker image — it is vendored in
# ./extensions-extra/ (mount it via docker-compose.yml).
if ( is_dir( "$IP/extensions/TemplateStyles" ) ) {
	wfLoadExtension( 'TemplateStyles' );    # templates carry their own CSS
}
# Popups (page previews on hover) — also vendored in ./extensions-extra/
if ( is_dir( "$IP/extensions/Popups" ) ) {
	wfLoadExtension( 'Popups' );
	$wgPopupsHideOptInOnPreferencesPage = true;
}
wfLoadExtension( 'TextExtracts' );          # summary extracts (used by Popups)
wfLoadExtension( 'PageImages' );            # lead images (used by Popups)
wfLoadExtension( 'CategoryTree' );          # category navigation
wfLoadExtension( 'Cite' );                  # <ref> / references
wfLoadExtension( 'CiteThisPage' );
wfLoadExtension( 'VisualEditor' );          # visual editing (core Parsoid)
wfLoadExtension( 'WikiEditor' );
wfLoadExtension( 'CodeEditor' );
wfLoadExtension( 'ImageMap' );              # clickable Plate I regions (optional)
wfLoadExtension( 'InputBox' );              # "create article" boxes on portals
wfLoadExtension( 'Interwiki' );             # future sister-wiki links

## Uploads
$wgEnableUploads = true;
$wgFileExtensions = array_merge( $wgFileExtensions, [ 'svg' ] );
$wgUseInstantCommons = false;

## Anti-spam: captcha on account creation + abuse filter framework
wfLoadExtension( 'ConfirmEdit' );
wfLoadExtension( 'ConfirmEdit/QuestyCaptcha' );
$wgCaptchaClass = 'QuestyCaptcha';
$wgCaptchaQuestions = [
	'How many Great Houses rule the Banner-lands? (a number)' => [ '10', 'ten' ],
	'Complete the tagline: "The map ends where the ... begins." (one word)' => [ 'truth' ],
	'What is sworn in the ash at the end of the war? (two words)' => [ 'ash oath', 'the ash oath' ],
];
$wgCaptchaTriggers['createaccount'] = true;
$wgCaptchaTriggers['edit'] = false;
$wgCaptchaTriggers['create'] = false;
wfLoadExtension( 'AbuseFilter' );
$wgGroupPermissions['sysop']['abusefilter-modify'] = true;

## Public fan wiki: readable by all, editable by registered users only
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createaccount'] = true;
$wgGroupPermissions['user']['edit'] = true;

## Nicer URLs (optional; see README before enabling behind a proxy)
# $wgArticlePath = "/wiki/$1";
# $wgUsePathInfo = true;

## Development namespace note: gate material lives in Category:Development
## and carries Template:Gate — nothing there is canon.
