/*
 *  $Id$
 *
 *  This file is part of the OpenLink Software Ajax Toolkit (OAT) project.
 *
 *  Copyright (C) 2009 OpenLink Software
 *
 *  See LICENSE file for details.
 *
 */


var qbe = {};
var adv = {};
var tab = {};
var tab_qbe = {};
var tab_query = {};
var page_w = 800;
var page_h = 800;

if (typeof(toolkitImagesPath) == 'undefined') var toolkitImagesPath = "/isparql/toolkit/images/";

/*
    OAT.Keyboard.add ('esc',   function() { dialogs.goptions.cancel(); },null, 'goptions');
    OAT.Keyboard.add ('return',function() { dialogs.goptions.ok(); },    null, 'goptions');
*/


function init() {
    try {
	iSPARQL.Common.initDefaults();
	iSPARQL.Common.handlePageParams();
	iSPARQL.Common.initData();

	// XXX cannot go without these global vars for now - too much refactoring involved

	iSPARQL.Common.initAdv(); // XXX warning defines global adv
	iSPARQL.Common.initQBE(); // XXX warning defines global qbe
        iSPARQL.Common.initQE();  // XXX warning defines global qe, uses qbe

	iSPARQL.Common.initUI();

	iSPARQL.Common.showUI();
	iSPARQL.Common.hideSplash();

	if (qbe.svgsparql) { qbe.svgsparql.reposition(); }

    } catch (e) {
	iSPARQL.Common.errMsg ('Internal Error: ' + e.toString());
	OAT.Dom.hide ("splashThrobber");
	OAT.Dom.show ("splashErrorImg");
	sessionStorage.clear();
	if (iSPARQL.Preferences.debug) throw (e);
    }


    OAT.Dom.show("page_content");

    /*    if (window.__inherited) {
	if (window.__inherited.username)       goptions.username = window.__inherited.username;
	if (window.__inherited.password)       goptions.password = window.__inherited.password;
	if (window.__inherited.login_put_type) goptions.login_put_type = window.__inherited.login_put_type;
	if (window.__inherited.endpoint)       goptions.service = window.__inherited.endpoint;
	if (window.__inherited.proxy)          goptions.proxy = window.__inherited.proxy;
	if (window.__inherited.should_sponge)  goptions.should_sponge = window.__inherited.should_sponge;
	if (window.__inherited.query)          qbe.loadFromString(window.__inherited.query);
	if (window.__inherited.graph)          $('qbe_graph').value = window.__inherited.graph;

	if (window.__inherited.callback) {
    */
	    /* query returning */
    /*	    var returnRef = function() {
		if ($v('default-graph-uri') == '' ||
		    confirm('WARNING ! ! !\nDefault graph will be lost, construct your query using FROM instead. \nDo you wish to continue?')) {
		    window.__inherited.callback($v('query'));
		    window.close();
		}
	    }
	    OAT.Dom.attach("return_btn","click",returnRef);
	} else OAT.Dom.hide("return_btn");

	if (!iSPARQL.Common.checkAuth(goptions.username,goptions.password) == true)
	    iSPARQL.dialogs.goptions.show();
	else if (window.__inherited.run) qbe.func_run();
    } else {
	OAT.Dom.hide("return_btn");

	var page_params = OAT.Dom.uriParams();
	for (var p in goptions) {
	    if (page_params['goptions.' + p] != undefined)
		goptions[p] = page_params['goptions.'+p];}

	if (fixed_sponge) {
	    goptions.should_sponge = fixed_sponge;
	    var inputs = document.getElementsByName('should-sponge');
	    for(var i = 0; i < inputs.length; i++) inputs[i].disabled = true;
	    $('qbe_sponge').disabled = true;
	    $('adv_sponge').disabled = true;
	}

	var show_initial_screen = true;

	if(get_initial_credentials)	{
	    OAT.AJAX.GET(get_initial_credentials, '', function(data,headers){
			     if (data != '') {
				 var tmp = OAT.Crypto.base64d(data).split(':');
				 if (tmp.length > 0) {
				     goptions.username = tmp[0];
				     goptions.password = tmp[1];
				 }
				 show_initial_screen = false;
			     }
			 },{async:false,onerror:function(xhr){alert(xhr.getResponseText());}});
	    if (!iSPARQL.Common.checkAuth(goptions.username,goptions.password) == true)
		show_initial_screen = true;
	}

		if (show_initial_screen) iSPARQL.dialogs.goptions.show();
		else goptions.initial_screen = true;

      } */


    if (OAT.Browser.isIE) {
	tab.go (1); /* is 0-based index... */
    }
}


/* FIXME: this is only used by Schemas, so it should go away.
 * Schemas should use its own query (caching mechanism)
 */

iSPARQL.QueryExec = function(optObj) {
    var self = this;

    this.options = {
	/* ajax */
	onstart:false,
	onend:false,
	onerror:false,
	errorHandler:function(xhr) {
	    var status = xhr.getStatus();
	    var response = xhr.getResponseText();
	    var headers = xhr.getAllResponseHeaders();
	    alert(response);
	},

	endpoint:"/sparql",
	query:false,
	format:"text/html",
	sponge:false,
	maxrows:0,
	callback:function(data,headers,param) {}
    };

    this.cache = {};

    this.go = function(optObj) {
	var opts = {};
	for (var p in self.options) { opts[p] = self.options[p]; }
	for (var p in optObj) { opts[p] = optObj[p]; }

	if (opts.query in self.cache) {
	    if (opts.callback) { opts.callback(self.cache[opts.query]); }
	    return;
	}

	var req = {
	    query:opts.query,
	    format:opts.format,
	};

	if (opts.defaultGraph && !opts.query.match(/from *</i)) { req["default-graph-uri"] = opts.defaultGraph; }
	if (opts.limit) { req["maxrows"] = opts.limit; }
	if (opts.sponge && self.options.virtuoso) { req["should-sponge"] = opts.sponge; }

	var arr = [];
	for (var p in req) {
	    arr.push(p+"="+encodeURIComponent(req[p]));
	}
	var query = arr.join("&");

	var callback = function(data) {
	    self.cache[opts.query] = data;
	    if (opts.callback) { opts.callback(data); }
	}

	var o = {
	    onerror:opts.errorHandler,
	    onstart:opts.onstart || function() { OAT.Dom.show("throbber"); },
	    onend:opts.onend || function() { OAT.Dom.hide("throbber"); },
	}

	OAT.AJAX.POST (opts.endpoint, query, callback, o);
    }

    self.go(optObj);
}

iSPARQL.Advanced = function () {
    var self = this;

    this.func_reset = function() {
	tab.go(tab_query);
	if(confirm('Are you sure you want to reset the query?')) {
	    iSPARQL.Common.resetSes();
	    self.redraw();
	}
    }

    this.redraw = function() {
	/* query */
	$("query").value = iSPARQL.dataObj.query;

	/* default graph */
	$("default-graph-uri").value = iSPARQL.dataObj.defaultGraph;

	}

    this.func_load = function() {
	var callback = function(path,file,data) {
	    iSPARQL.dataObj = data;
	    self.redraw();
	}

	iSPARQL.IO.load(callback);
    }

    this.func_save = function() {
	self.save();
    }

    this.func_saveas = function() {
	self.save();
    }

    this.func_run = function() {
	/* FIXME: what to do with these schmas/prefixes */
	/*
	  var prefixes = [];
	  var q = iSPARQL.dataObj.query;
	  var allPrefixes = q.match(/prefix\s+\w+:\s+<\S+>/mig) || [];
	  for(var i=0;i<allPrefixes.length;i++) {
	  var cur = allPrefixes[i];
	  var pref = cur.match(/prefix\s+(\w+):\s+<(\S+)>/i);
	  prefixes.push({"label":pref[1],"uri":pref[2]});
	  }

	  FIXME: catch also pragmas here
	*/

	var o = {
	    query:iSPARQL.dataObj.query,
	    defaultGraph:iSPARQL.dataObj.defaultGraph,
	    endpoint:iSPARQL.endpointOpts.endpointPath,
	    pragmas:iSPARQL.endpointOpts.pragmas,
	    namedGraphs:iSPARQL.dataObj.namedGraphs,
	    callback:iSPARQL.Common.setData
	}
	qe.execute(o);
    }

    this.func_load_to_qbe = function() {
	if (OAT.Browser.isIE) { return; }
	tab.go(tab_qbe);

	qbe.loadFromString($('query').value);
	if ($v('qbe_graph') == '')
	    $('qbe_graph').value = $v('default-graph-uri').trim();
	$('qbe_sponge').value = $v('adv_sponge');
	//qbe.redraw();
    }

    this.func_get_from_qbe = function() {
	tab.go(tab_query);
	if (OAT.Browser.isIE) return;

	//if (tab.selectedIndex != 1 && !tab_query.window) return;
	$('adv_sponge').value = $v('qbe_sponge');
	iSPARQL.Common.setQuery(qbe.QueryGenerate());
	iSPARQL.Common.setDefaultGraph($v('qbe_graph'));
	self.redraw();
    }

    this.save = function() {
	iSPARQL.IO.save(iSPARQL.dataObj);
    }

    var t = new OAT.Toolbar("toolbar");

    t.addIcon(0,"images/new.png","Reset",self.func_reset);
    t.addIcon(0,"images/open_h.png","Open",self.func_load);
    t.addIcon(0,"images/save_h.png","Save",self.func_save);
    t.addIcon(0,"images/save_as_h.png","Save As...",self.func_saveas);
    t.addSeparator();
    t.addIcon(0,"images/cr22-action-player_play.png","Run Query",self.func_run);

    /* msie does not support svg yet - probably never will */
    if (!OAT.Browser.isIE) {
	t.addSeparator();
	t.addIcon(0,"images/arrange.png","Visualize",self.func_load_to_qbe);
	t.addIcon(0,"images/compfile.png","Get from QBE",self.func_get_from_qbe);
    }
}

// XXX make OAT component

OAT.Observer = {
    add:function (observers, _obj, fun) {
	if (!OAT.Observer.find (observers, _obj, fun)) observers.push ({o:_obj, fun:fun});
    },
    del: function (observers, _obj, fun) {
	for (var i = 0; i < observers.length; i++)
	    if (observers[i].o == _obj && observers[i].fun == fun) {
		observers.splice(i,1);
		break;
	    }
    },
    // notify all but the initiator
    notify: function (observers, _obj, reason) {
	for (var i = 0;i < observers.length; i++)
	    if (typeof _obj != 'undefined' || observers[i].o != _obj)
		observers[i].fun (reason); // Why not have fun for no reason at all ? :)
    },
    find: function (observers, _obj, fun) {
	for (var i = 0;i < observers.length; i++) {
	    if (observers[i].o == _obj && observers[i].fun == fun)
		return true;
	    else
		return false;
	}
    }
}


//
// Observes SpongerOpts
//
// To avoid unwanted recursion we pass the calling object to the observed object.
//

iSPARQL.EndpointOptsUI = function (optsObj, toggler, indicator, container) {
    var self = this;

    this.togglerElm = $(toggler);
    this.containerElm = $(container);
    this.indicatorElm = $(indicator);
    this.epContainerElm = {};

    this.epCombo = {};
    this.opts = optsObj;

    this._init = function () {
	self.epCombo =  new OAT.Combolist(iSPARQL.defaults.endpoints,
					  "/sparql",
					  {name:"service", onchange:self.endpointChangeCB});
	self.epCombo.input.id = "service";
	self.epContainerElm = $('endpoint');
	self.epContainerElm.appendChild (self.epCombo.div);

	OAT.Observer.add (self.opts.observers, self, self.redraw);
	self.redraw();

	/* hidden by default */
	self.hideSeeAlsoControls();

	/* pragmas */
	OAT.Event.attach("cachingSchemesCtl","change", self.getOptChangeCB);
	OAT.Event.attach("nodesCrawledCtl",  "change", self.grabDepthChangeCB);
	OAT.Event.attach("nodesRetrievedCtl","change", self.grabLimitChangeCB);

	/* clicking on other traversal schemes hides grab:seealso controls */
	OAT.Event.attach("pathTravSchemesGraball", "change", self.grabAllChangeCB);
	OAT.Event.attach("pathTravSchemesDefault", "change", self.grabPropertiesChangeCB);

	/* and displaying shows them */
	OAT.Event.attach("pathTravSchemesSeealso", "change", self.grabSeeAlsoChangeCB);
	OAT.Event.attach("pathTravSchemesPreds",   "change", self.grabPredsChangeCB);

	/* Custom predicates: add predicate */
	OAT.Event.attach("spongerPredsAdd",    "click", self.showAddSeealso);
	OAT.Event.attach("pragmaAddPropAdd",   "click", self.addSeeAlsoPredicate);
	OAT.Event.attach("pragmaAddPropCancel","click", self.hideAddSeealso);

	/* remove selected predicate */
	OAT.Event.attach("spongerPredsDel","click", self.delSeeAlsoPredicate);

	/* restore default set of predicates (ask only if list length is not 0) */
	OAT.Event.attach("spongerPredsDefault","click",self.restoreSeeAlsoPredicates);

	/* input grab-var */
	OAT.Event.attach("spongerVars",   "change", self.grabVarsChangeCB);
	OAT.Event.attach("spongerVarsAdd","click",  self.addGrabVar);
	OAT.Event.attach("spongerVarsDel","click",  self.delGrabVar);

	/* endpoint combolist */

	self.opts.setEndpoint(self, $v("service"));

	if (iSPARQL.serverConn.isVirtuoso) {
	    OAT.Dom.show ("epvirtuosoindicator");
	    OAT.Dom.show ("derefOpts");
	}

	/* main display toggling */
	OAT.Event.attach (self.togglerElm, "click", self.toggle);

	if (typeof sessionStorage.iSPARQLEpOptsUIVisible != 'undefined' && sessionStorage.iSPARQLEpOptsUIVisible == 'true')
	    self.show();
	else
	    self.hide();

    }

    this.showEndpoints = function() {
	//	OAT.Dom.show ("endpoint");
    }

    this.endpointChangeCB = function(endpointElm) {
	self.opts.setEndpoint(self, endpointElm.value);
    }

    this.getOptChangeCB = function(getOptElm) {
	self.opts.setGetOpt (self, $v(getOptElm.target.options[getOptElm.target.selectedIndex]));
	// Disable sponge opts if sponger is disabled as well

	if (getOptElm.target.selectedIndex == 2)
	    {
		self.disableSpongerOptions ();
		iSPARQL.endpointOpts.resetPragmas();
	    }
	else
	    self.enableSpongerOptions ();
    }

    this.disableSpongerOptions = function () {
	$("nodesCrawledCtl").disabled = true;
	$("nodesRetrievedCtl").disabled = true;
	$("pathTravSchemesDefault").disabled = true;
	$("pathTravSchemesGraball").disabled = true;
	$("pathTravSchemesSeealso").disabled = true;

	self.hideSeeAlsoControls();
    }

    this.enableSpongerOptions = function () {
	$("nodesCrawledCtl").disabled = false;
	$("nodesRetrievedCtl").disabled = false;
	$("pathTravSchemesDefault").disabled = false;
	$("pathTravSchemesGraball").disabled = false;
	$("pathTravSchemesSeealso").disabled = false;

	if ($("pathTravSchemesSeealso").checked == true)
	    self.showSeeAlsoControls();
    }


    this.grabAllChangeCB = function (elm) {
	if (elm.target.checked) {
	    self.opts.setGrabAll (self);
	}
    }

    this.grabSeeAlsoChangeCB = function (elm) {
	if (elm.target.checked) {
	    self.showSeeAlsoControls();
	    self.opts.setSeeAlso (self);
        }
	else {
	    self.hideSeeAlsoControls();
	}
    }

    this.grabDepthChangeCB = function (elm) {
	self.opts.setGrabDepthPragma (self,
				      $("nodesCrawledCtl").options[$("nodesCrawledCtl").options.selectedIndex].value);
    }

    this.grabLimitChangeCB = function (elm) {
	self.opts.setGrabLimitPragma (self,
				      $("nodesRetrievedCtl").options[$("nodesRetrievedCtl").options.selectedIndex].value);
    }

    this.grabPropertiesChangeCB = function (elm) {
	//	self.opts.set
	return 0;
    }

    this.grabPredsChangeCB = function (elm) {
	return 0;
    }

    this.hideSeeAlsoControls = function() {
	OAT.Dom.hide("pathTravSchemesPredSelCtr");
    }

    this.showSeeAlsoControls = function() {
	OAT.Dom.show("pathTravSchemesPredSelCtr");
    }

    this.showAddSeealso = function() {
	OAT.Dimmer.show ($("pragmaAddProp"), {color:"#333", popup:false});
	$("pragmaAddPropPrefix").focus();
    }

    this.hideAddSeealso = function() {
	OAT.Dimmer.hide();
	$("pragmaAddPropPrefix").value = '';
	$("pragmaAddPropUri").value = '';
    }

    this.grabVarsChangeCB = function () {
	self.opts.setGrabVars (self, $("spongerVars").options);
    }

    this.addGrabVar = function() {
	var v = window.prompt("Variable name"); // XXX should add inline text field like in every other interface we have.

	if (!v) { return; }

	var l = $("spongerVars").options.length;
	$("spongerVars").options[l++] = new Option(v,v);

	if (l > 0) { OAT.Dom.show("spongerVars"); }

	self.opts.setGrabVars();
    }

    this.delGrabVar = function() {
	for (var i=0;i<$("spongerVars").options.length;i++) {
	    if ($("spongerVars").options[i].selected) {
		$("spongerVars").options[i] = null;
	    }
	}
	var l = $("spongerVars").options.length;
	if (l<1) { OAT.Dom.hide("spongerVars"); }

	self.opts.setGrabVars();
    }

    this.addSeeAlsoPredicate = function() {
	var prefix = $v("pragmaAddPropPrefix");
	var uri = $v("pragmaAddPropUri");
	if (!prefix.length || !uri.length) {
	    alert("Both prefix and URI must be entered.");
	    return;
	}

	for (var i=0;i<$("pathTravSchemesPreds").options.length;i++) {
	    if ($("pathTravSchemesPreds").options[i].text==prefix) {
		alert("Prefix "+prefix+" is already present in the list.");
		return;
	    }
	}

	var l = $("pathTravSchemesPreds").options.length;
	$("pathTravSchemesPreds").options[l] = new Option(prefix,uri);
	OAT.Dimmer.hide();
	$("pragmaAddPropPrefix").value = '';
	$("pragmaAddPropUri").value = '';

	self.opts.setGrabPragma();
    }

    /* remove selected predicate */
    this.delSeeAlsoPredicate = function() {
	for (var i=0;i<$("pathTravSchemesPreds").options.length;i++) {
	    if ($("pathTravSchemesPreds").options[i].selected) {
		$("pathTravSchemesPreds").options[i] = null;
	    }
	}
	self.opts.setGrabPragma();
    }

    this.restoreSeeAlsoPredicates = function() {
	if ($("pathTravSchemesPreds").options.length == 0
	    || window.confirm("This will remove custom added predicates. Really restore?")) {

	    $("pathTravSchemesPreds").options.length = 0;
	    $("pathTravSchemesPreds").options[0] = new Option('foaf:knows','http://xmlns.com/foaf/0.1/',true);
	    $("pathTravSchemesPreds").options[1] = new Option('sioc:links_to','http://rdfs.org/sioc/ns#',true);
	    $("pathTravSchemesPreds").options[2] = new Option('rdfs:isDefinedBy','http://www.w3.org/2000/01/rdf-schema#',true);
	    $("pathTravSchemesPreds").options[3] = new Option('rdfs:seeAlso','http://www.w3.org/2000/01/rdf-schema#',true);
	    $("pathTravSchemesPreds").options[4] = new Option('owl:sameAs','http://www.w3.org/2002/07/owl#',true);
	    }
	setGrabPragma();
    }

    this.setEpOptCtl = function () {
	self.epCombo.input.value = self.opts.endpointPath;
    };

    this.setPragmaSelect = function(pragma, select) {

	var p = self.opts.findPragma(pragma) || false;
	if (!p) { return; }

	var opts = $(select).options;
	for (var i=0;i<opts.length;i++) {
	    var opt = opts[i];
	    if (opt.value == p[1][0].replace (/"/g,'')) { //"
		$(select).options.selectedIndex = i;
		break;
	    }
	}
    },

    this.setPragmaRadio = function(pragma, radio) {
	var p = self.opts.findPragma(pragma) || false;
	if (!p) { return; }
	$(radio).checked = true;
    }

    this.setPragmaList = function(pragma,select) {
	var p = self.opts.findPragma(pragma) || false;
	if (!p) { return; }

	var values = p[1];
	var opts = $(select).options;
	for (var i=0;i<opts.length;i++) {
	    var opt = opts[i];
	    var index = values.find("<" + opt.value + ">");
	    $(select).options[i].selected = (index == -1)? false : true;
	}
    }

    this.setGetOptCtl = function () {
	self.setPragmaSelect('define get:soft', "cachingSchemesCtl");
    };

    this.setGrabLimitCtl = function () {
	self.setPragmaSelect('define input:grab-limit', "nodesRetrievedCtl");
    };

    this.setGrabDepthCtl = function () {
	self.setPragmaSelect('define input:grab-depth', "nodesCrawledCtl");
    }

    this.setPathTraversalCtl = function () {
	self.setPragmaRadio ('define input:grab-all',    "pathTravSchemesGraball");
	self.setPragmaRadio ('define input:grab-seealso',"pathTravSchemesSeealso");
	self.setPragmaList  ('define input:grab-seealso',"pathTravSchemesPreds");
    };

    this.setGrabVarCtl = function (callerObj, val) { return 0; }

    this.redraw = function (reason) {

	if (iSPARQL.serverConn.isVirtuoso)
	    OAT.Dom.show (self.epOptsContainer);
	else
	    OAT.Dom.hide (self.epOptsContainer);

	self.setEpOptCtl ();
	self.setGetOptCtl ();
	self.setGrabLimitCtl ();
	self.setGrabDepthCtl ();
	self.setGrabVarCtl ();
	self.setPathTraversalCtl ();
    }

    this.toggle = function () {
	if (self.containerElm.style.display == "none")
	    self.show();
	else
	    self.hide();
    }

    this.show = function () {
	OAT.Dom.show (self.containerElm);
	self.indicatorElm.innerHTML = "&#9662;";
	sessionStorage.iSPARQLEpOptsUIVisible = 'true';
    }

    this.hide = function () {
	OAT.Dom.hide (self.containerElm);
	self.indicatorElm.innerHTML = "&#9656;";
	sessionStorage.iSPARQLEpOptsUIVisible = 'false';
    }

    self._init ();
}

//
// EndpointOpts holds global endpoint-related options, it is observed by the EndpointOptsUI
//
// endpointPath
// pragmas
//
//

iSPARQL.EndpointOpts = function (optsObj) {
    var self = this;

    this.observers = [];

    this.endpointPath            = '/sparql';
    this.useProxy                = true;
    this.pragmas                 = [];

    // get:soft [replace|replacing|soft|none] - caching - control sponging
    // input:grab-all - overrides grab-seealso
    // input:grab-seealso [multiple]
    // input:grab-limit - max (serverLimit, user-input)
    // input:grab-depth - max (serverLimit, user-input)
    // input:grab-var [multiple values]
    // XXX add support for:
    // timeout

    this.unSerialize = function (s) {
	var o = OAT.JSON.parse (s);

	this.loadObj (o);
    };

    this.serialize = function () {
	var o = {endpointPath:self.endpointPath,
		 useProxy:    self.useProxy,
		 pragmas:     self.pragmas};

	return OAT.JSON.stringify (o);
    };

    this.loadSes = function () {
	if (typeof sessionStorage.iSPARQLEndpointOpts != 'undefined' && sessionStorage.iSPARQLEndpointOpts)
	self.unSerialize (sessionStorage.iSPARQLEndpointOpts);
    };

    this.saveSes = function () {
	sessionStorage.iSPARQLEndpointOpts = self.serialize();
    };

    this.loadObj = function (o) {
	self.endpointPath = o.endpointPath;
	self.useProxy = o.useProxy;
	self.pragmas = o.pragmas;
    }

    this._init = function (o) {
	if (o.sponge) {
	    self.setGetOpt (self,o.sponge);
	}
	// retrieve state from persistent session storage if available
	self.loadSes();
    };

    this.reset = function (caller) {
	self.endpointPath = '/sparql';
	self.useProxy = true;
	self.pragmas = [];
	OAT.Observer.notify (self.observers, callerObj, 'reset');
	self.saveSes();
    };

    this.setEndpoint = function (callerObj, val) {
	self.endpointPath = val;
	OAT.Observer.notify (self.observers, callerObj, 'setEndpoint');
	self.saveSes();
    };

    this.resetPragmas = function () {
	self.pragmas = [];
	self.saveSes();
    };

    this.setPragmas = function (pragmas) {
	for (var i = 0; i < pragmas.length; i++) {
	    var pragma = pragmas[i];

	    /* look for existing pragma defs in dataObj */
	    var index = -1;

	    for (var j=0;j<self.pragmas.length;j++) {
		var searched = self.pragmas[j];

		if (searched[0] == pragma[0]) {
		    index = j;
		    break;
		}
	    }

	    /* now, if our value is false, then delete them */
	    var value = pragma[1][0];

	    if (value) {
		if (index == -1) {
		    self.pragmas.push(pragma);
		}
		else {
		    self.pragmas[index] = pragma;
		}
	    } else {
		if (index != -1) {
		    self.pragmas.splice(index,1);
		}
	    }
	}
	iSPARQL.Common.log(self.pragmas);
	self.saveSes();
    };

    this.clearPragmas = function () {
	self.pragmas = [];
	self.saveSes();
    };

    this.setGetOpt = function (callerObj, val) {
	var a = [];

	if (val != 'none')
	    a.push(['define get:soft',[(val)? '"'+val+'"' : val]]);
	else {
	    a.push(['define get:soft',[false]]);
	    //	    a.push(['define input:grab-limit',[false]]); XXX will have to test which way is best for user (what happens to existing other
	    //	    a.push(['define input:grab-depth',[false]]); Sponger options if sponger is set to be off.
	    //	    a.push(['define input:grab-all',[false]]);
	    //	    a.push(['define input:grab-seealso',[false]]);
	}

	self.setPragmas(a);
	OAT.Observer.notify (self.observers, callerObj, 'setGetOpt');
    };

    this.hasGetOpt = function () {
	for (p in self.pragmas) {
	    if (p[0] == 'define get:soft') {
		return true;
	    }
	}
	return false;
    };

    this.renderPragmas = function () {
	return ("define get:soft 'soft'"); // XXX crash test dummy
    };

    /* grab-seealso/grab-all */
    this.setGrabAll = function(callerObj) {
	var a = [];

	a.push(['define input:grab-all',['"yes"']]);
	a.push(['define input:grab-seealso',[false]]); // Mutually exclusive option with grab-all

	self.setPragmas (a);
	OAT.Observer.notify (self.observers, callerObj, 'setGrabAll');
    }

    this.resetPathTraversal = function (callerObj) {
	var a = [];

	if ($("pathTravSchemesDefault").checked) {
	    a.push(['define input:grab-all',[false]]);
	    a.push(['define input:grab-seealso',[false]]);
	}

	self.setPragmas (a);
	OAT.Observer.notify (self.observers, callerObj, 'resetPathTraversal');
    }


    this.setSeeAlso = function (callerObj) {
	var v = [];
	var pref = [];
	var a = [];

	var preds = $("pathTravSchemesPreds").options;

	for (var i=0;i<preds.length;i++) {
	    var p = preds[i];

	    if (p.selected) { v.push("<" + p.text + ">"); pref.push(p.text + " = " + p.value); }
	}

	iSPARQL.Common.addPrefix (p);

	a.push(['define input:grab-all',[false]]);
	a.push(['define input:grab-seealso',v]);

	self.setPragmas(a);

	OAT.Observer.notify (self.observers, callerObj, 'resetPathTraversal');
    }

    this.setGrabVars = function (callerObj, vars) {
	var a = [];
	var v = [];

	for (var i=0;i<vars.length;i++) {
	    var item = vars[i];
	    if (item.selected) { v.push("?" + item.value); }
	}

	a.push(['define input:grab-var',v]);

	self.setPragmas(a);
	OAT.Observer.notify (self.observers, callerObj, 'setGrabVars');
    }

    this.setGrabLimitPragma = function(callerObj, lim) {
	var a = [];

	a.push (['define input:grab-limit', [ lim ] ]);

	self.setPragmas(a);
	OAT.Observer.notify (self.observers, callerObj, 'setGrabLimit');
    }

    this.setGrabDepthPragma = function(callerObj, depth) {
	var a = [];

	a.push(['define input:grab-depth', [ depth ] ]);

	self.setPragmas(a);
	OAT.Observer.notify (self.observers, callerObj, 'resetPathTraversal');
    },

    this.findPragma = function (name) {

	for (var i=0;i<self.pragmas.length;i++) {
	    var pragma = self.pragmas[i];
	    if (pragma[0] == name) { return pragma;}
	}

	return false;
    }

    this._init(optsObj);
};

iSPARQL.MetaDataOptsUI = function (optsObj, toggler, indicator, container) {
    var self = this;
    this.containerElm = $(container);
    this.togglerElm = $(toggler);
    this.indicatorElm = $(indicator);

    this.opts = optsObj;
    this.opts.observers = [];

    this._init = function () {
	OAT.Observer.add (self.opts.observers, self, self.redraw);

	self.redraw ('Init');

	OAT.Event.attach ("mdtitle",       "change", self.titleChangeCB);
	OAT.Event.attach ("mddescription", "change", self.descrChangeCB);
	OAT.Event.attach ("mdcreator",     "change", self.creatorChangeCB);
	OAT.Event.attach (self.togglerElm, "click",  self.toggle);
    }

    this.titleChangeCB = function () {
	self.opts.setTitle (self, $v("mdtitle"));
    }

    this.descrChangeCB = function () {
	self.opts.setDescription (self, $v("mddescription"));
    }

    this.creatorChangeCB = function () {
	self.opts.setCreator (self, $v("mdcreator"));
    }

    this.redraw = function (reason) {
	$("mdtitle").value = self.opts.metadata.title;
	$("mdcreator").value = self.opts.metadata.creator;
	$("mddescription").value = self.opts.metadata.description;
    }

    this.toggle = function () {
	if (self.containerElm.style.display == "none")
	    self.show();
	else
	    self.hide();
    }

    this.show = function () {
	OAT.Dom.show (self.containerElm);
	self.indicatorElm.innerHTML = "&#9662;";
    }

    this.hide = function () {
	OAT.Dom.hide (self.containerElm);
	self.indicatorElm.innerHTML = "&#9656;";
    }

    self._init ();
};

__NOP = function () { return; } // a test

iSPARQL.MetaDataOpts = function () {

    var self = this;

    this.metadata = {};
    this.observers = {};

    this._init = function () {
	self.reset();
	if (typeof sessionStorage.iSPARQLMetaDataOpts != 'undefined' && sessionStorage.iSPARQLMetaDataOpts)
	    self.metadata = OAT.JSON.parse (sessionStorage.iSPARQLMetaDataOpts);
    }

    this.reset = function (caller) {
	self.metadata.title = "";
	self.metadata.creator = "";
	self.metadata.description = "";

	if (caller) OAT.Observer.notify (self.observers, caller, 'reset');
    }

    this.loadOpts = function (o) {
	if (o.title) self.metadata.title       = o.title;
	if (o.title) self.metadata.creator     = o.creator;
	if (o.title) self.metadata.description = o.description;
    }

    this.changed = function (callerObj, reason) {
	sessionStorage.iSPARQLMetaDataOpts = OAT.JSON.stringify (self.metadata);
	OAT.Observer.notify (self.observers, callerObj, 'setCreator');
    }

    this.setTitle  = function (callerObj, val) {
	self.metadata.title = val;0
	self.changed(callerObj, 'setTitle');
    }

    this.setCreator = function (callerObj, val) {
	self.metadata.creator = val;
	self.changed(callerObj, 'setCreator');
    }

    this.setDescription = function (callerObj, val) {
	self.metadata.description = val;
	self.changed(callerObj, 'setDescription')
    }

    this.getMetaDataObj = function () {
	return self.metadata;
    }

    this._init();
};

iSPARQL.AuthUI = function (connection) {
    var self = this;

    this.dlg = new OAT.Dialog ("Endpoint User Login", "auth_dlg", {width:400,modal:0,buttons:0});

    this.userElm = $("auth_dlg_user");
    this.passElm = $("auth_dlg_pass");
    this.loginB  = $("auth_login_b");
    this.cancelB = $("auth_cancel_b");
    this.errElm  = $("auth_dlg_error");

    this.loginIndicatorB = $("login_b");

    this.connection = {};

    this._init = function (conn) {
	OAT.Dom.attach(self.loginB, 'click', self.loginCB);
	OAT.Dom.attach(self.cancelB, 'click', self.cancelCB);

	if (typeof connection != undefined)
	    self.connection = conn;

	OAT.Observer.add (self.connection.observers, self, self.connChanged);
	OAT.Dom.attach (self.loginIndicatorB, 'click', self.dlg.show);
	self.resetIndicator();
    }

    this.resetIndicator = function () {
	if (self.connection.connected) {
	    self.loginIndicatorB.innerHTML = "Logged in as " + self.connection.authObj.user;

	} else {
	    self.loginIndicatorB.innerHTML = "Login";
	}
    }

    this.connChanged = function () {
	self.resetIndicator ();
    }

    this.show = function () {
	self.dlg.show ();
    }

    this.hide = function () {
	self.dlg.hide ();
    }

    this.loginCB = function (elm) {
	self.errElm.innerHTML = '';
	self.connection.connect ($v(self.userElm), $v(self.passElm));

	if (self.connection.connected)
	    self.dlg.hide();
	else
	    self.errElm.innerHTML = "Error: " + self.connection.error;
    }

    this.cancelCB = function (elm) {
	self.userElm.value="";
	self.passElm.value="";
	self.dlg.hide();
    }

    this._init(connection);
}

iSPARQL.ServerConnection = function (uri, authObj) {
    var self = this;
    this.endpointUri = uri;

    this.authObj = OAT.JSON.parse(OAT.JSON.stringify(authObj)); // Deep copy param obj

    this.connected = false;
    this.response = false;
    this.error = false;
    this.relogin_required = false;

    this.observers = [];

    this._init = function () {
	self.loadAuth ();
	self.connect (self.authObj.user, self.authObj.pass);
        return;
    };

    // Newest IE, FireFox and Safari/WebKit implement HTML 5.0 local storage

    this.saveAuth = function() {
	sessionStorage.iSPARQLAuth = OAT.JSON.stringify (self.authObj);
    };

    this.loadAuth = function() {
	if (typeof sessionStorage.iSPARQLAuth != 'undefined' && sessionStorage.iSPARQLAuth)
	self.authObj = OAT.JSON.parse (sessionStorage.iSPARQLAuth);
    };

    this.connect = function (_user, _pass, caller) {
	self.authObj.user = _user;
	self.authObj.pass = _pass;
	self.connected = false;

	OAT.AJAX.GET (self.authObj.endpoint, 'username=' + _user + '&pass=' + _pass,
		      function (data, headers) {
			  if (data == 'OK') self.connected = true;
			  else self.error = data;
		      },
		      {async:false, onstart:function(){return}, onerror:function (xhr) { self.error = xhr.response; self.connected = false; }});

	if (self.connected) {
	    self.saveAuth ();
	    OAT.WebDav.init({imageExt:"png", silentStart:true, user:self.authObj.user,pass:self.authObj.pass, isDav:true});
	}

	self.detectServerProperties ();

	OAT.Observer.notify (self.observers, caller, "connect");
    }

    this.detectServerProperties = function() {
	// determine server type, if virtuoso we show virtuoso specifics
	iSPARQL.Common.statMsg ("Detecting endpoint properties&#8230;");
	OAT.AJAX.GET ('./version',
		      '',
		      function (data,headers) {

			  if (headers.match(/VIRTUOSO/i)) {
			      self.isVirtuoso = true;
			  }
			  else {
			      self.isVirtuoso = false;
			      self.serverVersion = false;
			      self.serverBuildDate = false;
			  }

			  var tmp = data.split("/");

			  if (tmp && tmp.length > 1) {
			      self.serverVersion = tmp[0];
			      self.serverBuildDate = tmp[1];
			  }
		      },{async:false, onstart:function(){return}});
    }

    this._init();
}

//
// Some common functions - options/variables are kept as direct children of global iSPARQL and iSPARQL.dataObj
//
//

iSPARQL.Common = {

    //
    // XXX: serverDefaults set by a .vsp kludge causing, among other things, invalid HTML to be sent to client
    //  - should be moved into a web service and gotten the same way we get /Version
    //

    //
    // Override app defaults with server settings, etc.
    //

    initDefaults: function () {
	for (var defName in iSPARQL.serverDefaults) {
	    if (defName == 'auth')
		{
		    for (var authParm in iSPARQL.serverDefaults.auth) {
			if (authParm in ['user', 'pass'] && iSPARQL.serverDefaults.auth[authParm] == '') // Empty user/pass do not override defaults
			    continue;
			else
			    iSPARQL.defaults.auth[authParm] = iSPARQL.serverDefaults.auth[authParm];
		    }
		    continue;
		}
	    iSPARQL.defaults[defName] = iSPARQL.serverDefaults[defName];
	}
    },

    // page params may override defaults

    handlePageParams:function () {

	var qp = false;
	var p = OAT.Dom.uriParams();

	if (p['default-graph-uri']) { iSPARQL.defaults.graph = p['default-graph-uri']; qp = true; }
	if (p['query'])             { iSPARQL.defaults.query = p['query']; qp = true; }
	if (p['sponge'])            { iSPARQL.defaults.sponge = p['sponge']; qp = true; }
	if (p['should_sponge'])     { iSPARQL.defaults.sponge = p['should_sponge']; qp = true; }
	if (p['view'])
	    {
		var tabInx = parseInt(page_params['view']);
		if (!isNaN(tabInx) && tabinx >= 0 && tabInx < 3)
		    iSPARQL.defaults.tab = tabInx;
		qp = true;
	    }

	if (qp) iSPARQL.defaults.qp_override = qp;
	if (p['__DEBUG']) iSPARQL.Preferences.debug = true;

    },

    hideSplash: function () {
	OAT.Dom.hide("splash");
    },

    statMsg: function(msg, isMain) {
	if (isMain)
	    $("statMsgMain").innerHTML = msg;
	else
	    $("statMsgElem").innerHTML = msg;
    },

    errMsg: function (msg) {
	$("statMsgErr").innerHTML = msg;
    },

    initData:function () {
	iSPARQL.Common.statMsg ("Initializing data structures and objects&#8230;");

	// Set program defaults

	iSPARQL.Common.reset();
	iSPARQL.Common.setQuery (iSPARQL.dataObj.query);
	iSPARQL.Common.setDefaultGraph (iSPARQL.dataObj.graph);

	iSPARQL.mdOpts       = new iSPARQL.MetaDataOpts ();
	iSPARQL.endpointOpts = new iSPARQL.EndpointOpts ({sponge:iSPARQL.defaults.sponge});
	iSPARQL.serverConn   = new iSPARQL.ServerConnection (iSPARQL.endpointOpts.endpointPath,
							     iSPARQL.defaults.auth);
    },

    initUI:function () {
	iSPARQL.Common.statMsg ("UI initialization started&#8230;");
	OAT.Dom.hide ("throbber");
	OAT.Event.attach("throbber","click",OAT.AJAX.cancelAll);

	/* fix image paths */
	if (toolkitImagesPath.match(/[^\/]$/)) { toolkitImagesPath += "/"; }

	OAT.Preferences.imagePath = toolkitImagesPath;
	OAT.AJAX.imagePath = toolkitImagesPath;
	OAT.Anchor.imagePath = toolkitImagesPath;
	OAT.WebDav.options.imagePath = toolkitImagesPath;

	OAT.AJAX.httpError = 0;

	/* about XXX should just have OK/Dismiss button */

        iSPARQL.Common.statMsg ("Creating dialogs&#8230;");

	iSPARQL.dialogs = {};

	iSPARQL.dialogs.about = new OAT.Dialog("About iSPARQL","about_dlg",{width:400,modal:0,buttons:0});
	OAT.Dom.attach ("about_dlg_b_ok", "click", iSPARQL.dialogs.about.hide);

	/* help XXX should just have OK/Dismiss button */

	iSPARQL.dialogs.help = new OAT.Dialog("iSPARQL Help", "help_dlg", {width:400, modal:0, buttons:0});
	OAT.Dom.attach ("help_dlg_b_ok", "click", iSPARQL.dialogs.help.hide);

	iSPARQL.dialogs.prefs = new OAT.Dialog("iSPARQL Preferences", "prefs_dlg", {width:400, modal:1});
	iSPARQL.dialogs.prefs.ok = iSPARQL.dialogs.prefs.hide;
	iSPARQL.dialogs.prefs.cancel = iSPARQL.dialogs.prefs.hide;

	if (iSPARQL.serverConn.isVirtuoso) {
	    $('about_version').innerHTML = iSPARQL.serverConn.serverVersion;
	    $('about_date').innerHTML = iSPARQL.serverConn.serverBuildDate;
	}
	else {
	    $('about_version').innerHTML = 'N/A (Not Virtuoso)';
	    $('about_date').innerHTML =  'N/A (Not Virtuoso)';
	}

	$('about_oat_version').innerHTML = OAT.Preferences.version;
	$('about_oat_build').innerHTML = OAT.Preferences.build;
	$('throbber').src = OAT.Preferences.imagePath + "Dav_throbber.gif";

	OAT.Anchor.zIndex = 1001;

        iSPARQL.Common.statMsg ("Initializing menu&#8230;");
	iSPARQL.Common.initMenu();

	var tab_goCallback = function (oldIndex, newIndex) {
	    if (OAT.Browser.isIE && iSPARQL.dialogs.qbe_unsupp && newIndex == 0) {
		iSPARQL.dialogs.qbe_unsupp.show();
		return;
	    }
	}

	var onUnDock = function(newIndex) {
	    if (newIndex == 0) {
		var x = 720;
		if (OAT.Browser.isMac) x -= 20;
		qbe.props_win.moveTo(x,42);
		qbe.schema_win.moveTo(x,182);
	    }
	}

	var onDock = function(newIndex) {
	    if (newIndex == 0) {
		qbe.props_win.moveTo(page_w - 260,92);
		qbe.schema_win.moveTo(page_w - 260,232);
	    }
	}

	tab = new OAT.Tab ("main_col",
				{dockMode:true,
					dockElement:"tabs",
					goCallback:tab_goCallback,
					onDock:onDock,
					onUnDock:onUnDock,
					dockWindowWidth:1000,
					dockWindowHeight:600});

	tab_qbe =     tab.add ("tab_qbe",    "page_qbe");
	tab_query =   tab.add ("tab_query",  "page_query");
	tab_results = tab.add ("tab_results","page_results");

	tab.go (0); /* is 0-based index... */

	var tabgraphs = new OAT.Tab ("tabgrph_content");
	tabgraphs.add ("tabgrph_default","tabgrph_default_content");
	tabgraphs.add ("tabgrph_named","tabgrph_named_content");
	tabgraphs.go (0);

	// Click event to get file name for save

	OAT.Dom.attach ("browse_btn", "click", iSPARQL.Common.fileRef);

	var loadToQBE = OAT.Dom.create("li",{},"nav");
	loadToQBE.title = 'Load query into QBE';
	var img = OAT.Dom.create("img");
	img.src = "images/arrange.png";

	OAT.Dom.attach(loadToQBE,
		       'click',
		       function() { /* load to QBE */
			   tab.go(tab_qbe);
			   var cache = qe.cache[qe.cacheIndex];
			   qbe.loadFromString(cache.opts.query);
			   $('qbe_sponge').value = cache.opts.sponge;
			   $('service').value = cache.opts.endpoint;
		       });

	OAT.Dom.append([qe.dom.ul,loadToQBE],[loadToQBE,img]);

	var loadToAdvanced = OAT.Dom.create("li",{},"nav");
	loadToAdvanced.title = 'Load query in Advanced view';
	var img = OAT.Dom.create("img");
	img.src = "images/cr22-action-edit.png";

	OAT.Dom.attach(loadToAdvanced,'click',function(){
			   tab.go(tab_query);
			   var cache = qe.cache[qe.cacheIndex];
			   $('query').value = cache.opts.query;
			   $('default-graph-uri').value = cache.opts.defaultGraph;
			   $('adv_sponge').value = cache.opts.sponge;
			   $('service').value = cache.opts.endpoint;
		       });

	OAT.Dom.append([qe.dom.ul,loadToAdvanced],[loadToAdvanced,img]);

	/* qbe_unsupp */
	iSPARQL.dialogs.qbe_unsupp = new OAT.Dialog("Unsupported","qbe_unsupported_div",{width:400,modal:1});
	iSPARQL.dialogs.qbe_unsupp.ok = function() {
	    tab.go(1);
	    iSPARQL.dialogs.qbe_unsupp.hide();
	}

	iSPARQL.dialogs.qbe_unsupp.cancel = iSPARQL.dialogs.qbe_unsupp.ok;

	iSPARQL.Common.statMsg ("MetaData UI&#8230;");
	iSPARQL.mdUI = new iSPARQL.MetaDataOptsUI (iSPARQL.mdOpts,
						   'mdtoggler', 'mdoptstogglerarrow', 'mdopts_ctr');

	iSPARQL.Common.statMsg ("Endpoint Options UI&#8230;");
	iSPARQL.epUI = new iSPARQL.EndpointOptsUI (iSPARQL.endpointOpts,
						   'endpoint_opts_toggler',
						   'endpointoptstogglerarrow',
						   'endpoint_opts');

	iSPARQL.Common.statMsg ("Auth UI&#8230;");
	iSPARQL.authUI = new iSPARQL.AuthUI (iSPARQL.serverConn);

	OAT.Resize.create("query_resizer_area", "query_div", OAT.Resize.TYPE_X);
	OAT.Resize.create("query_resizer_area", "query", OAT.Resize.TYPE_Y);
	$("query_resizer_area").style.backgroundImage = 'url("'+OAT.Preferences.imagePath+"resize.gif"+'")';
	$("query_resizer_area").style.cursor = "nw-resize";

	OAT.Dom.attach ("query",
			"keyup",
			function () { iSPARQL.Common.setQuery ($v("query")); });

	OAT.Dom.attach ("default-graph-uri",
			"keyup",
			function() { iSPARQL.Common.setDefaultGraph($v("default-graph-uri")); });

	OAT.Dom.attach ("query",
		       "change",
		       function() { iSPARQL.Common.setQuery($v("query")); });

	OAT.Dom.attach ("default-graph-uri",
		       "change",
		       function() { iSPARQL.Common.setDefaultGraph($v("default-graph-uri")); });

	/* get content even after user pasted something (via menu/middlemouse), which wont trigger the events above */

	OAT.Dom.attach ("query",
		       "mouseout",
		       function() { iSPARQL.Common.setQuery($v("query")); });

	OAT.Dom.attach("default-graph-uri",
		       "mouseout",
		       function() { iSPARQL.Common.setDefaultGraph($v("default-graph-uri")); });

	// Help menu dismiss button

	/* build info */
	$("foot_r").innerHTML += " OAT Version " + OAT.Preferences.version + " Build " + OAT.Preferences.build;

	page_w = OAT.Dom.getWH('page')[0] - 20;

	$('default-graph-uri').value = iSPARQL.defaults.graph;
	$('query').value = iSPARQL.defaults.query;

        iSPARQL.Common.statMsg ("UI Initialization complete.");
    },
    initAdv: function () {
	iSPARQL.Common.statMsg ('Initializing Text Query Interface&#8230;');
	window.adv = new iSPARQL.Advanced();
    },
    initQBE:function () {
	iSPARQL.Common.statMsg ('Initializing QBE &#8230;');

	init_qbe(); // Customise svgsparql prototype

	window.qbe = new iSPARQL.QBE(iSPARQL.defaults);

	qbe.loadFromString(iSPARQL.defaults.query);
    },
    initQE: function() {
	iSPARQL.Common.statMsg ('Initializing Query Execution faciltity&#8230;');
	var execCB = function(req) {
	    /* FIXME: nicely call redraw here */
	    tab.go(2); /* go to results after query execution */
	    if (qbe.QueryGenerate() == req.opts.query) { return; }
	    qbe.loadFromString (req.opts.query);
	    qbe.svgsparql.reposition();

	    $("query").value = req.opts.query;
	    $("qbe_graph").value = req.opts.defaultGraph;
	}

	window.qe = new QueryExec({div:"page_results", executeCallback:execCB});
    },
    showUI: function() {
	OAT.Dom.show ("page_content");
    },
    toggleVisibility: function (elem_id) {
	if ($(elem_id).style.display == 'none')
	    OAT.Dom.show (elem_id);
	else
	    OAT.Dom.hide (elem_id);
    },
    enableFileOps: function () {
	OAT.Dom.attach ("menu_b_load",
			"click",
			function() {
			    if (tab.tabs.find (tab_qbe) == tab.selectedIndex) qbe.func_load();
			    if (tab.tabs.find (tab_query) == tab.selectedIndex) adv.func_load();
			});
	OAT.Dom.removeClass ("menu_b_load", "disabled")

	OAT.Dom.attach("menu_b_save",
		       "click",
		       function() {
			   if (tab.tabs.find(tab_qbe) == tab.selectedIndex) qbe.func_save();
			   if (tab.tabs.find(tab_query) == tab.selectedIndex) adv.func_save();
		       });
	OAT.Dom.removeClass ("menu_b_save", "disabled")

	OAT.Dom.attach ("menu_b_saveas",
			"click",
			function() {
			    if (tab.tabs.find(tab_qbe) == tab.selectedIndex) qbe.func_saveas();
			    if (tab.tabs.find(tab_query) == tab.selectedIndex) adv.func_saveas();
			});
	OAT.Dom.removeClass ("menu_b_saveas", "disabled")
    },
    disableFileOps: function () {
	OAT.Dom.detach ("menu_b_load",
			"click",
			function() {
			    if (tab.tabs.find (tab_qbe) == tab.selectedIndex) qbe.func_load();
			    if (tab.tabs.find (tab_query) == tab.selectedIndex) adv.func_load();
			});
	OAT.Dom.addClass ("menu_b_load", "disabled");

	OAT.Dom.detach("menu_b_save",
		       "click",
		       function() {
			   if (tab.tabs.find(tab_qbe) == tab.selectedIndex) qbe.func_save();
			   if (tab.tabs.find(tab_query) == tab.selectedIndex) adv.func_save();
		       });
	OAT.Dom.addClass ("menu_b_save", "disabled");

	OAT.Dom.detach ("menu_b_saveas",
			"click",
			function() {
			    if (tab.tabs.find(tab_qbe) == tab.selectedIndex) qbe.func_saveas();
			    if (tab.tabs.find(tab_query) == tab.selectedIndex) adv.func_saveas();
			});
	OAT.Dom.addClass ("menu_b_saveas", "disabled");

    },
    serverConnectObserver: function (reason) {
	if (reason == 'connect')
	    iSPARQL.Common.enableFileOps();
	else
	    iSPARQL.Common.disableFileOps();
    },
    initMenu: function() {
	var m = new OAT.Menu();
	m.noCloseFilter = "noclose";
	m.createFromUL("menu");

	// Attach events
	OAT.Dom.attach ("menu_b_reset",
			"click",
			function() {
			    if (tab.tabs.find (tab_qbe) == tab.selectedIndex) qbe.func_clear();
			    if (tab.tabs.find (tab_query) == tab.selectedIndex) adv.func_reset();
			});

	OAT.Dom.attach ("menu_b_run",
			"click",
			function() {
			    if (tab.tabs.find(tab_qbe) == tab.selectedIndex) qbe.func_run();
			    if (tab.tabs.find(tab_query) == tab.selectedIndex) adv.func_run();
			});

	OAT.Dom.attach ("menu_b_help", "click", iSPARQL.dialogs.help.show);

	OAT.Dom.attach("menu_b_qbe", "click", function (){
			   tab.go (tab_qbe);
		       });

	OAT.Dom.attach("menu_b_adv", "click", function (){
			   tab.go (tab_query);
		       });

	OAT.Dom.attach("menu_b_about", "click", iSPARQL.dialogs.about.show);
	OAT.Dom.attach("menu_b_prefs", "click", iSPARQL.dialogs.prefs.show);

	OAT.Observer.add (iSPARQL.serverConn.observers, this, this.serverConnectObserver);
    },

    log:function(msg) {
	if(!!(window.console) && iSPARQL.Preferences.debug) {
	    window.console.log(msg);
	}
    },

    getFilePath:function() {
	var path = '/DAV';

	if (iSPARQL.dataObj.user)
	    path += "/home/" + iSPARQL.dataObj.user;

	if (iSPARQL.dataObj.lastPath)
	    path = iSPARQL.dataObj.lastPath.substring(0,iSPARQL.dataObj.lastPath.lastIndexOf("/"));

	return path;
    },

    getFile:function() {
	var file = '';

	if (iSPARQL.dataObj.lastPath)
	    file = iSPARQL.dataObj.lastPath.substring(iSPARQL.dataObj.lastPath.lastIndexOf("/") + 1,
						      iSPARQL.dataObj.lastPath.length);

	return file;
    },

    /* get file name for saving */

    fileRef:function() {
	var path = iSPARQL.Common.getFilePath();
	var pathDefault = iSPARQL.Common.getDefaultPath();

	var ext = $v('savetype');

	var name = OAT.Dav.getNewFile(path,'.' + ext);
	if (!name) { return; }
	if (name.slice(name.length-ext.length - 1).toLowerCase() != "." + ext) { name += "." + ext; }
	$("save_name").value = name;
    },

    getDefaultPath:function() {
	var path = '/DAV';

	if (iSPARQL.dataObj.user) path += "/home/" + iSPARQL.dataObj.user;

	var pathDefault = path;

	if (iSPARQL.dataObj.user == 'dav') pathDefault = '/DAV';

	return pathDefault;
    },

    getAuthFromCookie:function () {
	return ({user:'dav', pass:'dav'});
    },

    saveAuthCookie: function () {
    },


    addNamedGraph:function(graph) {
	var index = iSPARQL.dataObj.namedGraphs.find(graph);
	if (index != -1) { return; }
	iSPARQL.dataObj.namedGraphs.push(graph);
	iSPARQL.Common.log(iSPARQL.dataObj.namedGraphs);
    },

    removeNamedGraph:function(graph) {
	var index = iSPARQL.dataObj.namedGraphs.find(graph);
	if (index == -1) { return; }
	iSPARQL.dataObj.namedGraphs.splice(index,1);
	iSPARQL.Common.log(iSPARQL.dataObj.namedGraphs);
    },

    addGraph:function(graph) {
	var index = iSPARQL.dataObj.graphs.find(graph);
	if (index != -1) { return; }
	iSPARQL.dataObj.graphs.push(graph);
	iSPARQL.Common.log(iSPARQL.dataObj.graphs);
    },

    addPrefix:function(prefix) {
	var index = iSPARQL.dataObj.prefixes.find(prefix);
	if (index != -1) { return; }
	iSPARQL.dataObj.prefixes.push(prefix);
	iSPARQL.Common.log(iSPARQL.dataObj.prefixes);
    },

    removeGraph:function(graph) {
	var index = iSPARQL.dataObj.graphs.find(graph);
	if (index == -1) { return; }
	iSPARQL.dataObj.graphs.splice(index,1);
	iSPARQL.Common.log(iSPARQL.dataObj.graphs);
    },

    setQuery:function(query) {
	iSPARQL.dataObj.query = query;
	iSPARQL.Common.log(iSPARQL.dataObj.query);
    },

    setDefaultGraph:function(graph) {
	iSPARQL.dataObj.defaultGraph = graph;
	iSPARQL.Common.log(iSPARQL.dataObj.defaultGraph);
    },

    setData:function(data) {
	iSPARQL.dataObj.data = data;
	iSPARQL.Common.log(iSPARQL.dataObj.data);
    },

    // sessionStorage handling
    //
    // XXX should abstract better for better code reuse - have OAT Component for cross-browser(version) compat
    //

    resetSes:function () {
	sessionStorage.iSPARQLSes = '';
	iSPARQL.Common.reset();
    },

    saveSes:function () {
	sessionStorage.iSPARQLSes = OAT.JSON.stringify (iSPARQL.dataObj);
    },

    loadSes: function () {
	if (typeof sessionStorage.iSPARQLSes != 'undefined' && sessionStorage.iSPARQLSes)
	    iSPARQL.dataObj = OAT.JSON.parse (sessionStorage.iSPARQLSes);
    },

    //
    // Set program default options - will be overriden by server defaults if available
    // Also user may reset - should reinit EndpointOpts and metaDataOpts
    //

    reset:function() {
	if (typeof iSPARQL == 'undefined') iSPARQL = {};
	if (typeof iSPARQL.dataObj == 'undefined') iSPARQL.dataObj = {};

	iSPARQL.dataObj.data = false;
	iSPARQL.dataObj.query = iSPARQL.defaults.query;
	iSPARQL.dataObj.defaultGraph = "";
	iSPARQL.dataObj.graphs = [];
	iSPARQL.dataObj.namedGraphs = [];
	iSPARQL.dataObj.prefixes = [];			/* FIXME: prefixes? */

	iSPARQL.dataObj.pragmas = [];
	iSPARQL.dataObj.canvas = false;
	iSPARQL.dataObj.sponge = iSPARQL.defaults.sponge;
	iSPARQL.dataObj.tab = iSPARQL.defaults.tab;

	if (typeof iSPARQL.endpointOpts != 'undefined') iSPARQL.endpointOpts.reset();
	if (typeof iSPARQL.metaDataOpts != 'undefined') iSPARQL.metaDataOpts.reset();

	this.loadSes ();
	this.log(iSPARQL.dataObj);

    },

    /* named graphs */

    initNamedGraphsList:function () {
	var table = $('named_graph_list');

	if (table.tBodies.length) { OAT.Dom.unlink(table.tBodies[0]); }
	$('named_graphs_cnt').innerHTML = 0;

	for (var i=0;i<iSPARQL.dataObj.namedGraphs.length;i++) {
	    add_named_graph(iSPARQL.dataObj.namedGraphs[i]);
	}
    },
}

function get_file_type(file_name) {
    if (file_name.match(/isparql\.xml$/i)) return 'isparql';
    else return file_name.substring(file_name.lastIndexOf(".") + 1);
}

// XXX why OAT.AJAX.AUTH_BASIC and why not use DAV methods instead of a separate VSP page??
//     where is this code referenced??
//     check set_dav_props.vsp
//


function set_dav_props(res){
    var ext = res.substring(res.lastIndexOf('.') + 1).toLowerCase();
    if (iSPARQL.serverConn.isVirtuoso && (ext == 'xml' || ext == 'isparql' || ext == 'rq')) {
	OAT.AJAX.GET('./set_dav_props.vsp?res=' + encodeURIComponent(res),
		     '',
		     function () {return '';},
		     {user:iSPARQL.dataObj.user,
			     password:iSPARQL.dataObj.pass,
			     auth:OAT.AJAX.AUTH_BASIC,
			     onstart:function(xhr){return},
			     onerror:function(xhr){alert(xhr.getResponseText());}});
    }
}

function prefix_insert(){
    prefix = $v('prefix');
    if ($v('query').indexOf(prefix) == -1)
	$('query').value = prefix + '\n' + $v('query');
}

//
function template_insert(){
    template = $v('template');
    insert_text($('query'),template);
    $('template').selectedIndex = 0;
}

function tool_invoke(){
    tool = $v('tool');
    eval(tool);
    $('tool').selectedIndex = 0;
}

function tool_put(txt){
    insert_text($('query'),txt);
}

function tool_put_line_start(txt){
    var query = $('query');
    var query_value = $v('query').replace("\r",'');
    var lines = query_value.split("\n");

    var pos = getPos(query);
    start = pos[0];
    end   = pos[1];
    var nl = 0;
    if (start < end) nl = 1;
    var from  = strCountLines(query_value.substring(0,start));
    var to    = strCountLines(query_value.substring(start,end - nl)) + from;

    var res = '';
    var cnt = 0;
    for(var i=0;i<lines.length;i++) {
	if ( from <= i && i <= to ) {
	    res += txt + lines[i];
	    cnt++;
	} else res += lines[i];
	if (i < lines.length - 1) res += "\n";
    }
    query.value = res;
    //alert(res.charAt(start - 1 - OAT.Browser.isIE));
    if (!((res.charAt(start - 1 - OAT.Browser.isIE) == "\n" || start == 0) && start != end)) start = start + txt.length;

    if (cnt > 1) end = end + (cnt * txt.length) - (OAT.Browser.isIE * (cnt - 1));
    else end = end + txt.length;

    setPos(query, start, end);
    query.focus();
}


function tool_rem_line_start(txt){
    var query = $('query');
    var query_value = $v('query').replace("\r",'');
    var lines = query_value.split("\n");

    var pos = getPos(query);
    var start = pos[0];
    var end   = pos[1];
    var nl = 0;
    if (start < end) nl = 1;
    var from  = strCountLines(query_value.substring(0,start));
    var to    = strCountLines(query_value.substring(start,end - nl)) + from;

    var res = '';
    var cnt = 0;
    for(var i=0;i<lines.length;i++) {
	if ( from <= i && i <= to && lines[i].substring(0,txt.length) == txt) {
	    res += lines[i].substring(txt.length);
	    cnt++;
	} else res += lines[i];
	if (i < lines.length - 1) res += "\n";
    }
    query.value = res;

    if (cnt > 0) {
	if (!((res.charAt(start - 1 - OAT.Browser.isIE) == "\n" || start == 0) && start != end)) start = start - txt.length;
	if (cnt > 1) end = end - (cnt * txt.length) - (OAT.Browser.isIE * (cnt - 1));
	else end = end - txt.length;
    }
    setPos(query, start, end);
    query.focus();
}


function tool_put_around(btxt,atxt){
    var elm = $('query');
    var start = 0;
    var end = 0;

    var pos = getPos(elm);
    start = pos[0];
    end   = pos[1];

    var txt = elm.value.substring(start,end);

    insert_text(elm,btxt + txt + atxt);
}


function insert_text(elm,txt){
    var start = 0;
    var end = 0;

    var pos = getPos(elm);
    start = pos[0];
    end   = pos[1];

    elm.value = elm.value.substring(0,start) + txt + elm.value.substring(end,elm.value.length);

    end = start + txt.length;
    setPos(elm, start, end);
    elm.focus();

}

function setPos(elm, start, end) {
    if (typeof elm.selectionStart != "undefined" && typeof elm.selectionEnd != "undefined") {
	elm.setSelectionRange(start, end);
    } else if (document.selection && document.selection.createRange) {
	var range_new = elm.createTextRange ();
	range_new.move ("character", start - strCountLines(elm.value.substring(0,start)));
	range_new.moveEnd ("character", end - start);
	range_new.select ();
    }
}


function getPos(elm) {
    if (typeof elm.selectionStart != "undefined" && typeof elm.selectionEnd != "undefined") return [elm.selectionStart,elm.selectionEnd];

    elm.focus();
    var range = document.selection.createRange();
    var stored_range = range.duplicate();
    stored_range.moveToElementText( elm );
    stored_range.setEndpoint( 'EndToEnd', range );
    return [stored_range.text.length - range.text.length,stored_range.text.length];
};

function strCountLines(txt){
    var cnt = 0;
    if (txt.length < 1) return 0;
    for(var i=1;i<=txt.length;i++) {
	if(txt.substring(i-1, i) == "\n") {
	    cnt++;
	}
    }
    return cnt;
};


var toolswin = null;

function tools_popup(){
    if (toolswin == null) {
	var topbox_ctl_xy = OAT.Dom.getLT('topbox_ctl');
	toolswin = new OAT.Window({close:1,min:0,max:0,x:topbox_ctl_xy[0] + 200,y:topbox_ctl_xy[1] + 50,width:200,height:440,title:"Statement Help"});
	toolswin.div.style.zIndex = 1013;
	$("page_query").appendChild(toolswin.div);
	toolswin.onclose = function() { OAT.Dom.hide(toolswin.div); }

	var tools = $('tool').options;
	toolswin.content.innerHTML = '';
	for (i = 0;i<tools.length;i++) {
	    if (tools[i].value)
		toolswin.content.innerHTML += '<button class="tools_but" onclick="' + tools[i].value.replace(/\"/g,'&quot;') + '">' + tools[i].text + '</button>';
	}
    }
    OAT.Dom.show(toolswin.div);
}

function add_named_graph(graph) {
    var named_graph = $v('named_graph_add') || graph;

    if (!named_graph) {
	alert('Please fill in named graph value.');
	return false;
    }

    if (!graph && iSPARQL.dataObj.namedGraphs.find(named_graph) != -1) {
	alert('Graph already present.');
	return false;
    }

    var table = $('named_graph_list');

    if (!table.tBodies.length) {
	var body = OAT.Dom.create("tbody");
	table.appendChild(body);
    }

    var row = OAT.Dom.create("tr");

    var boxCell = OAT.Dom.create("td");
    boxCell.style.textAlign = "center";

    var boxCheck = OAT.Dom.create("input");
    boxCheck.type = "checkbox";
    boxCheck.checked = "checked";

    var graphCell = OAT.Dom.create("td");
    graphCell.innerHTML = '<input type="text" readonly style="width: 440px;" value="'+named_graph+'"/>';

    var delCell = OAT.Dom.create("td");
    delCell.style.textAlign = "center";

    var delButton = OAT.Dom.create("button");
    delButton.innerHTML = '<img src="images/edit_remove.png" title="del" alt="del"/> del';

    OAT.Dom.append([delCell,delButton],[boxCell,boxCheck],[row,boxCell,graphCell,delCell],[table.tBodies[0],row]);

    OAT.Dom.attach(delButton,"click",function() {
		       OAT.Dom.unlink(row);
		       $('named_graphs_cnt').innerHTML--;
		       if (!table.tBodies[0].rows.length) OAT.Dom.unlink(table.tBodies[0]);
		       iSPARQL.Common.removeNamedGraph(named_graph);
		   });

    OAT.Dom.attach(boxCheck,"click",function() {
		       if (iSPARQL.dataObj.namedGraphs.find(named_graph) == -1) {
			   iSPARQL.Common.addNamedGraph(named_graph);
		       } else {
			   iSPARQL.Common.removeNamedGraph(named_graph);
		       }
		   });

    if (!graph)
	iSPARQL.Common.addNamedGraph(named_graph);

    $('named_graphs_cnt').innerHTML++;
    $('named_graph_add').value = '';
}


