--
--  $Id$
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2012 OpenLink Software
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--
--

DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>registry_get('_dbpedia_path_'));
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/class');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/ontology');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data2');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data3');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/page');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/resource');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/category');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/statics');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/wikicompany/resource');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/sparql');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/property');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data4');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/about');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/snorql');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/sparql-auth');


--# root proxy to dbpedia wiki
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/',
	 ppath=>registry_get ('dbp_website'),
	 is_dav=>0,
	 def_page=>''
);

DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>rtrim (registry_get('_dbpedia_path_'), '/'),
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba'
);

--# class
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/class',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 opts=>vector ('url_rewrite', 'dbp_rule_list_3')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_3', 1, vector ('dbp_rule_6', 'dbp_rule_7', 'dbp_rule_18', 'dbp_rule_19'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_6', 1, '(/[^#]*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description.vsp?res=%U', vector ('par_1'), NULL, NULL, 2, 0, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_7', 1, '/class/(.*)\x24', vector ('par_1'), 1,
'/data2/%s.rdf', vector ('par_1'), NULL, 'application/rdf.xml', 2, 303, 'Content-Type: application/rdf+xml');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_18', 1, '/class/(.*)\x24', vector ('par_1'), 1,
'/data2/%s.n3', vector ('par_1'), NULL, 'text/rdf.n3', 2, 303, 'Content-Type: text/rdf+n3');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_19', 1, '/class/(.*)\x24', vector ('par_1'), 1,
'/data2/%s.n3', vector ('par_1'), NULL, 'application/x-turtle', 2, 303, 'Content-Type: application/x-turtle');

--# ontology
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/ontology',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 opts=>vector ('url_rewrite', 'dbp_rule_list_owl')
);


DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_owl', 1, vector ('owl_rule_6', 'owl_rule_7', 'owl_rule_18', 'owl_rule_19'));
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'owl_rule_6', 1, '(/[^#]*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description.vsp?res=%U', vector ('par_1'), NULL, NULL, 2, 0, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'owl_rule_7', 1, '/ontology/(.*)\x24', vector ('par_1'), 1,
'/data3/%s.rdf', vector ('par_1'), NULL, 'application/rdf.xml', 2, 303, 'Content-Type: application/rdf+xml');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'owl_rule_18', 1, '/ontology/(.*)\x24', vector ('par_1'), 1,
'/data3/%s.n3', vector ('par_1'), NULL, 'text/rdf.n3', 2, 303, 'Content-Type: text/rdf+n3');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'owl_rule_19', 1, '/ontology/(.*)\x24', vector ('par_1'), 1,
'/data3/%s.n3', vector ('par_1'), NULL, 'application/x-turtle', 2, 303, 'Content-Type: application/x-turtle');


--# data
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data',
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba',
	 opts=>vector ('url_rewrite', 'dbp_data_rule_list', 'url_rewrite_keep_lpath', 1)
);

create procedure DB.DBA.DBP_GRAPH_PARAM1 (in par varchar, in fmt varchar, in val varchar)
{
  declare tmp any;
  tmp := sprintf ('default-graph-uri=%U', registry_get ('dbp_graph'));
  if (par = 'gr')
    {
      val := trim (val, '/');
      if (length (val) = 0)
	val := '';
      if (val = 'en')
        val := '';  
      if (val <> '')
	{
          val := 'http://' || val || '.dbpedia.org';	
	  tmp := tmp || sprintf ('&named-graph-uri=%U', val);
	}
    }
  else
    tmp := val;
  return sprintf (fmt, tmp);
}
;

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_data_rule_list', 1, vector ('dbp_data_rule0', 'dbp_data_rule1', 'dbp_data_rule2', 'dbp_data_rule3', 'dbp_data_rule3-1', 'dbp_data_rule3-2', 'dbp_data_rule4', 'dbp_data_rule5', 'dbp_data_rule6', 'dbp_data_rule7', 'dbp_data_rule8'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule0', 1, '/data/([a-z_\\-]*/)?(.*)', vector ('gr', 'par_1'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=rdf',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule1', 1, '/data/([a-z_\\-]*/)?(.*)', vector ('gr', 'par_1'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=%U',
vector ('gr', 'par_1', '*accept*'), 'DB.DBA.DBP_GRAPH_PARAM1', '(application/rdf.xml)|(text/rdf.n3)', 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule2', 1, '/data/([a-z_\\-]*/)?(.*)\\.(xml)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=rdf',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule3', 1, '/data/([a-z_\\-]*/)?(.*)\\.(ttl)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=n3',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule3-1', 1, '/data/([a-z_\\-]*/)?(.*)\\.(nt)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=nt',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule3-2', 1, '/data/([a-z_\\-]*/)?(.*)\\.(n3)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=text%%2Fn3',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule5', 1, '/data/([a-z_\\-]*/)?(.*)\\.(jrdf)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&output=application%%2Frdf%%2Bjson',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, 'Content-Type: application/rdf+json\r\n^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule6', 1, '/data/([a-z_\\-]*/)?(.*)\\.(json)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3Cdbp_resource_decoded' || registry_get('dbp_resource_decoded') || '%%3E&output=application%%2Fjson',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, 'Content-Type: application/json\r\n^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule4', 1, '/data/([a-z_\\-]*/)?(.*)\\.(rdf)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=define+sql:describe-mode+"DBPEDIA"+DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&format=%U',
vector ('gr', 'par_1', 'f'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, '^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule7', 1, '/data/([a-z_\\-]*/)?(.*)\\.(atom)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&output=application%%2Fatom%%2Bxml',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, 'Content-Type: application/atom+xml\r\n^{sql:DB.DBA.DBP_LINK_HDR}^');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_data_rule7', 1, '/data/([a-z_\\-]*/)?(.*)\\.(jsod)', vector ('gr', 'par_1', 'f'), 1,
'/sparql?%s&query=DESCRIBE+%%3C' || registry_get('dbp_resource_decoded') || '%%3E&output=application%%2Fodata%%2Bjson',
vector ('gr', 'par_1'), 'DB.DBA.DBP_GRAPH_PARAM1', NULL, 2, null, 'Content-Type: application/odata+json\r\n^{sql:DB.DBA.DBP_LINK_HDR}^');

--# data2
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data2',
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba',
	 opts=>vector ('url_rewrite', 'pvsp_rule_list7')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'pvsp_rule_list7', 1, vector ('pvsp_data_rule7'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'pvsp_data_rule7', 1, '/data2/(.*)\\.(n3|rdf)', vector ('par_1','f'), 1,
'/sparql?default-graph-uri='||registry_get('dbp_graph_decoded')||'&query=DESCRIBE+%%3Chttp%%3A%%2F%%2Fdbpedia.org%%2Fclass%%2F%U%%3E&format=%U',
vector ('par_1', 'f'), NULL, NULL, 2, null, '');

--# data3
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data3',
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba',
	 opts=>vector ('url_rewrite', 'pvsp_rule_data3')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'pvsp_rule_data3', 1, vector ('pvsp_data3_rule', 'pvsp_data3_rule_2', 'pvsp_data3_rule_3'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'pvsp_data3_rule', 1, '/data3/(.*)\\.(n3|rdf|ttl)', vector ('par_1', 'f'), 1,
'/sparql?default-graph-uri=http%%3A%%2F%%2F'||replace(registry_get('dbp_graph'),'http://','')||'&query=DESCRIBE+%%3Chttp%%3A%%2F%%2Fdbpedia.org%%2Fontology%%2F%U%%3E&format=%U',
vector ('par_1', 'f'), NULL, NULL, 2, NULL, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'pvsp_data3_rule_2', 1, '/data3/(.*)\\.(atom)', vector ('par_1', 'f'), 1,
'/sparql?default-graph-uri=http%%3A%%2F%%2F'||replace(registry_get('dbp_graph'),'http://','')||'&query=DESCRIBE+%%3Chttp%%3A%%2F%%2Fdbpedia.org%%2Fontology%%2F%U%%3E&format=application%%2Fatom%%2Bxml',
vector ('par_1'), NULL, NULL, 2, NULL, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'pvsp_data3_rule', 1, '/data3/(.*)\\.(ntriples)', vector ('par_1', 'f'), 1,
'/sparql?default-graph-uri=http%%3A%%2F%%2F'||replace(registry_get('dbp_graph'),'http://','')||'&query=DESCRIBE+%%3Chttp%%3A%%2F%%2Fdbpedia.org%%2Fontology%%2F%U%%3E&format=text%%2Fplain',
vector ('par_1'), NULL, NULL, 2, NULL, '');

--# page
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/page',
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 opts=>vector ('url_rewrite', 'dbp_rule_list_7')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_7', 1, vector ('dbp_rule_13'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_13', 1, '(/[^#\\?]*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description.vsp?res=%U', vector ('par_1'), NULL, NULL, 0, 0, '');

--# resource
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/resource',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 opts=>vector ('url_rewrite', 'dbp_rule_list_2')
);

create procedure DB.DBA.DBP_LINK_HDR (in in_path varchar)
{
  declare host, lines, accept, loc, alt, exp any;
  lines := http_request_header ();
--  dbg_obj_print ('in_path: ', in_path);
--  dbg_obj_print ('lines: ', lines);
  loc := ''; alt := ''; exp := '';
  host := http_request_header(lines, 'Host', null, '');
  if (regexp_match ('/data/([a-z_\\-]*/)?(.*)\\.(nt|n3|rdf|ttl|jrdf|xml|atom|json|jsod|ntriples)', in_path) is null and in_path like '/data/%')
    {
      declare tmp any;
      accept := http_request_header(lines, 'Accept', null, 'application/rdf+xml');
      accept := regexp_match ('(application/rdf.xml)|(text/rdf.n3)|(text/n3)', accept);
      tmp := split_and_decode (in_path, 0, '\0\0/');
      if (length (tmp) and strstr (http_header_get (), 'Content-Location') is null)
	{
	  tmp := tmp [ length (tmp) - 1 ];
	  if (accept is null)
	    accept := 'application/rdf+xml';
	  if (accept = 'application/rdf+xml')
	    loc := 'Content-Location: ' || tmp || '.xml\r\n';	
	  else if (accept = 'text/rdf+n3')
	    loc := 'Content-Location: ' || tmp || '.n3\r\n';	
	  else if (accept = 'text/n3')
	    loc := 'Content-Location: ' || tmp || '.n3\r\n';	
	}
    }
  if (in_path like '/data/%')
    {
      declare ext any;
      declare p varchar;
      ext := vector (vector ('xml', 'RDF/XML', 'application/rdf+xml'), vector ('n3', 'N3/Turtle', 'text/n3'), vector ('json', 'RDF/JSON', 'application/json'));
      foreach (any ss in ext) do
	{
	  declare s varchar;
	  s := ss[0];
	  if (in_path not like '/data/%.'||s)
	    {
	      p := regexp_replace (in_path, '\\.(nt|n3|rdf|ttl|jrdf|xml|json|atom|jsod|ntriples)\x24', '.'||s);
	      alt := alt || sprintf ('<http://%s%s>; rel="alternate"; type="%s"; title="Structured Descriptor Document (%s format)", ', host, p, ss[2], ss[1]);
	    }
	}
      if (in_path not like '/data/%.atom')
	{
	  p := regexp_replace (in_path, '\\.(nt|n3|rdf|ttl|jrdf|xml|json|atom)\x24', '.atom');
	  alt := alt || sprintf ('<http://%s%s>; rel="alternate"; type="application/atom+xml"; title="OData (Atom+Feed format)", ', host, p);
	}
      if (in_path not like '/data/%.jsod')
	{
	  p := regexp_replace (in_path, '\\.(nt|n3|rdf|ttl|jrdf|xml|json|atom)\x24', '.jsod');
	  alt := alt || sprintf ('<http://%s%s>; rel="alternate"; type="application/odata+json"; title="OData (JSON format)", ', host, p);
	}
      p := regexp_replace (in_path, '\\.(n3|nt|rdf|ttl|jrdf|xml|json|atom)\x24', '');
      p := replace (p, '/data/', '/page/');
      alt := alt || sprintf ('<http://%s%s>; rel="alternate"; type="text/html"; title="XHTML+RDFa", ', host, p);
      p := replace (p, '/page/', '/resource/');
      alt := alt || sprintf ('<http://%s%s>; rev="http://xmlns.com/foaf/0.1/primaryTopic", ', host, p);
      alt := alt || sprintf ('<http://%s%s>; rel="describedby", ', host, p);
      if (registry_get ('dbp_pshb_hub') <> 0)
	alt := alt || sprintf ('<%s>; rel="hub", ', registry_get ('dbp_pshb_hub'));
      exp := sprintf ('Expires: %s\r\n', date_rfc1123 (dateadd ('day', 7, now ())));
    }
  return sprintf ('%s%sLink: %s<http://mementoarchive.lanl.gov/dbpedia/timegate/http://%s%s>; rel="timegate"', exp, loc, alt, host, in_path);
}
;

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_2', 1, vector ('dbp_rule_14', 'dbp_rule_12'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_14', 1, '/resource/(.*)\x24', vector ('par_1'), 1,
    '/page/%s', vector ('par_1'), NULL, NULL, 2, 303, '^{sql:DB.DBA.DBP_LINK_HDR}^');

create procedure DB.DBA.DBP_DATA_IRI1 (in par varchar, in fmt varchar, in val varchar)
{
  if (par = 'par_2' and length (val))
    {
      declare arr any;
      arr := split_and_decode (val);
      if (length (arr) > 1 and arr[1] <> 'en' and length (arr[1]))
	return sprintf (fmt, arr[1] || '/');
      val := '';
    }
  return sprintf (fmt, val);
}
;
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_12', 1, '/resource/([^\\?]*)(\\?lang=.*)?\x24', vector ('par_1', 'par_2'), 1,
    '/data/%s@__@%s', vector ('par_2', 'par_1'), 'DB.DBA.DBP_DATA_IRI1', 
    '(application/rdf.xml)|(text/rdf.n3)|(text/n3)|(application/x-turtle)|(application/rdf.json)|(application/json)|(application/atom.xml)|(application/odata.json)', 2, 303, '^{sql:DB.DBA.DBP_LINK_HDR}^');

create procedure DB.DBA.DBP_TCN_LOC (in id any, in var any)
{
  return var;
}
;


delete from DB.DBA.HTTP_VARIANT_MAP where VM_RULELIST = 'dbp_rule_list_2';
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.xml',  'application/rdf+xml', 0.95, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.n3',   'text/n3', 0.80, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.nt',   'text/rdf+n3', 0.80, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.ttl',  'application/x-turtle', 0.70, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.json', 'application/json', 0.60, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.jrdf', 'application/rdf+json', 0.60, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.atom', 'application/atom+xml', 0.50, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_2', '@__@(.*)', '/data/\x241.jsod', 'application/odata+json', 0.50, location_hook=>null);

--# category
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/category',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 opts=>vector ('url_rewrite', 'dbp_rule_list_category')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_category', 1, vector ('dbp_rule_category14', 'dbp_rule_category12'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_category14', 1, '/category/(.*)\x24', vector ('par_1'), 1,
    '/page/%s', vector ('par_1'), NULL, NULL, 2, 303, NULL);

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_rule_category12', 1, '/category/(.*)\x24', vector ('par_1'), 1,
    '/data/__%U', vector ('par_1'), NULL, '(application/rdf.xml)|(text/rdf.n3)|(application/x-turtle)|(application/rdf.json)|(application/json)', 2, 303);

delete from DB.DBA.HTTP_VARIANT_MAP where VM_RULELIST = 'dbp_rule_list_category';
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_category', '__(.*)', '\x241.xml', 'application/rdf+xml', 0.95, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_category', '__(.*)', '\x241.n3',  'text/rdf+n3', 0.80, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_category', '__(.*)', '\x241.ttl',  'application/x-turtle', 0.70, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_category', '__(.*)', '\x241.json',  'application/json', 0.60, location_hook=>null);
DB.DBA.HTTP_VARIANT_ADD ('dbp_rule_list_category', '__(.*)', '\x241.jrdf',  'application/rdf+json', 0.60, location_hook=>null);


--# statics
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/statics',
	 ppath=>'/DAV/VAD/dbpedia/statics/',
	 is_dav=>1,
	 def_page=>'index.html'
);

--# wikicompany
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/wikicompany/resource',
	 ppath=>'/DAV/wikicompany/resource/',
	 is_dav=>1,
	 vsp_user=>'dba',
	 opts=>vector ('url_rewrite', 'dbp_wc_rule_list1')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_wc_rule_list1', 1, vector ('dbp_wc_rule1', 'dbp_wc_rule2'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_wc_rule1', 1, '(/[^#]*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description_white.vsp?res=%s', vector ('par_1'), NULL, NULL, 2, 0, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbp_wc_rule2', 1, '(/[^#]*)', vector ('par_1'), 1,
'/sparql?query=describe%%20%%3Chttp%%3A%%2F%%2Fdbpedia.openlinksw.com%s%%3E%%20from%%20%%3Chttp%%3A%%2F%%2Fdbpedia.openlinksw.com%%2Fwikicompany%%3E&format=%U',
vector ('par_1', '*accept*'), NULL, '(application/rdf.xml)|(text/rdf.n3)', 2, 303, '');

--# sparql
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/sparql',
	ppath=>'/!sparql/',
	is_dav=>1,
	def_page=>'',
	vsp_user=>'dba',
	opts=>vector ('noinherit', 'yes')
);

--# property
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/property',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 opts=>vector ('url_rewrite', 'dbp_rule_list_prop')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbp_rule_list_prop', 1, vector ('prop_rule_6', 'prop_rule_7', 'prop_rule_18', 'prop_rule_19'));
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'prop_rule_6', 1, '(/[^#\\?]*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description.vsp?res=%U', vector ('par_1'), NULL, NULL, 0, 0, '');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'prop_rule_7', 1, '/property/(.*)\x24', vector ('par_1'), 1,
'/data4/%s.rdf', vector ('par_1'), NULL, 'application/rdf.xml', 2, 303, 'Content-Type: application/rdf+xml');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'prop_rule_18', 1, '/property/(.*)\x24', vector ('par_1'), 1,
'/data4/%s.n3', vector ('par_1'), NULL, 'text/rdf.n3', 1, 303, 'Content-Type: text/rdf+n3');

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'prop_rule_19', 1, '/property/(.*)\x24', vector ('par_1'), 1,
'/data4/%s.n3', vector ('par_1'), NULL, 'application/x-turtle', 2, 303, 'Content-Type: application/x-turtle');

--# data4
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/data4',
	 ppath=>registry_get('_dbpedia_path_'),
	 is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba',
	 opts=>vector ('url_rewrite', 'pvsp_rule_data4')
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'pvsp_rule_data4', 1, vector ('pvsp_data4_rule'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'pvsp_data4_rule', 1, '/data4/(.*)\\.(n3|rdf)', vector ('par_1', 'f'), 1,
'/sparql?default-graph-uri='||registry_get('dbp_graph_decoded')||'&query=DESCRIBE+%%3C'||registry_get('dbp_property_decoded') || '%%3E&format=%U',
vector ('par_1', 'f'), NULL, NULL, 2, null, '');

--# about 
DB.DBA.VHOST_DEFINE (
	 lhost=>registry_get ('dbp_lhost'),
	 vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/about',
	 ppath=>'/SOAP/Http/ext_http_proxy',
	 is_dav=>0,
	 soap_user=>'PROXY',
	 ses_vars=>0,
	 opts=>vector ('url_rewrite', 'ext_about_http_proxy_rule_list1'),
	 is_default_host=>0
);

DB.DBA.URLREWRITE_CREATE_RULELIST ( 
    'ext_about_http_proxy_rule_list1', 1, 
      vector ('dbp_about_rule_1'));

DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 
    'dbp_about_rule_1', 1, 
      '/about/html/(.*)\x24', 
      vector ('par_1'), 
      1, 
      '/DAV/VAD/dbpedia/description.vsp?res=%U', 
      vector ('par_1'), 
      NULL, 
      NULL, 
      2, 
      0, 
      '' 
      );

DB.DBA.VHOST_REMOVE (
	 lhost=>registry_get ('dbp_lhost'),
	 vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/rdfdesc');
DB.DBA.VHOST_DEFINE (
	 lhost=>registry_get ('dbp_lhost'),
	 vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/rdfdesc',
	 ppath=>'/DAV/VAD/rdf_mappers/rdfdesc/',
	 is_dav=>1,
	 vsp_user=>'dba',
	 ses_vars=>0,
	 is_default_host=>0
);

--# snorql
DB.DBA.VHOST_DEFINE (
	 lhost=>registry_get ('dbp_lhost'),
	 vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/snorql',
	 ppath=>'/snorql/',
	 is_dav=>0,
	 def_page=>'index.html',
	 vsp_user=>'dba',
	 ses_vars=>0,
	 opts=>vector ('browse_sheet', 0),
	 is_default_host=>0
);

--# sparql-auth
DB.DBA.VHOST_DEFINE (
	 lhost=>registry_get ('dbp_lhost'),
	 vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/sparql-auth',
	 ppath => '/!sparql/',
	 is_dav => 1,
	 vsp_user => 'dba',
	 opts => vector('noinherit', 1),
	 auth_fn=>'DB.DBA.HP_AUTH_SPARQL_USER',
	 realm=>'SPARQL',
	 sec=>'digest');

--# other init code

create procedure ensure_demo_user ()
{
    if (exists (select 1 from SYS_USERS where U_NAME = 'demo'))
	return;
	exec ('create user "demo"');
	DB.DBA.user_set_qualifier ('demo', 'Demo');
};

ensure_demo_user ();

drop procedure ensure_demo_user;

create procedure create_demo_home ()
{
  declare pwd any;
  pwd := (select pwd_magic_calc (U_NAME, U_PASSWORD, 1) from SYS_USERS where U_NAME = 'dav');
  DAV_COL_CREATE ('/DAV/home/', '110100100', http_dav_uid(), http_dav_uid() + 1, 'dav', pwd);
  DAV_COL_CREATE ('/DAV/home/demo/', '110100100', http_dav_uid(), http_dav_uid() + 1, 'dav', pwd);
  DAV_COL_CREATE ('/DAV/home/demo/dbpedia/', '110100100', http_dav_uid(), http_dav_uid() + 1, 'dav', pwd);
};

create_demo_home ();
drop procedure create_demo_home;

create procedure upload_isparql ()
{
  declare base varchar;
  declare pwd any;
  pwd := (select pwd_magic_calc (U_NAME, U_PASSWORD, 1) from SYS_USERS where U_NAME = 'dav');
  base := registry_get('_dbpedia_path_');
  if (base like '/DAV/%')
    {
      for select RES_FULL_PATH from WS..SYS_DAV_RES where RES_FULL_PATH like base||'%.isparql' do
	{
	  DAV_COPY (RES_FULL_PATH, '/DAV/home/demo/dbpedia/', 0, '111101101NN', 'dav', 'administrators', 'dav', pwd);
	}
    }
  else
    {
      declare arr any;
      arr := sys_dirlist (base);
      foreach (varchar f in arr) do
	{
	  if (f like '%.isparql')
	    DAV_RES_UPLOAD ('/DAV/home/demo/dbpedia/'||f, file_to_string (base||f), '', '110100100R', http_dav_uid(), http_dav_gid(), 'dav', pwd);
	}
    }
  -- the current trigger of isparql have bug
  update WS..SYS_DAV_RES set RES_PERMS = '110100100NN' where RES_FULL_PATH like '/DAV/home/demo/dbpedia/%';
}
;

upload_isparql ();
drop procedure upload_isparql;


--# void & iSPARQL non-default VDs
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void/data');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void/page');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql/view');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql/defaults');

DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void',
	 ppath=>'/',
	 is_dav=>0,
	 def_page=>'',
	 ses_vars=>0,
	 opts=>vector ('url_rewrite', 'dbpl_void_rule_list'),
	 is_default_host=>0
);

DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void/data',
	 ppath=>'/DAV/VAD/dbpedia/',
	 is_dav=>1,
	 vsp_user=>'dba',
	 ses_vars=>0,
	 opts=>vector ('url_rewrite', 'dbpl_void_data_rule_list'),
	 is_default_host=>0
);

DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/void/page',
	 ppath=>'/DAV/VAD/dbpedia/',
	 is_dav=>1,
	 ses_vars=>0,
	 opts=>vector ('url_rewrite', 'dbpl_void_page_rule_list'),
	 is_default_host=>0
);
    
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql',
	 ppath=>'/DAV/VAD/iSPARQL/',
	 is_dav=>1,
	 def_page=>'index.html',
	 vsp_user=>'dba',
	 ses_vars=>0,
	 is_default_host=>0
);
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql/view',
	 ppath=>'/DAV/VAD/iSPARQL/',
	 is_dav=>1,
	 def_page=>'execute.html',
	 vsp_user=>'dba',
	 ses_vars=>0,
	 is_default_host=>0
);
DB.DBA.VHOST_DEFINE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/isparql/defaults',
	 ppath=>'/DAV/VAD/iSPARQL/',
	 is_dav=>1,
	 def_page=>'defaults.vsp',
	 vsp_user=>'dba',
	 ses_vars=>0,
	 is_default_host=>0
);

create procedure DB.DBA.SPARQL_DESC_DICT_DBPEDIA_PHYSICAL 
(in subj_dict any, in consts any, in good_graphs any, in bad_graphs any, in storage_name any, in options any)
{
  declare res, subjs any;
  res := DB.DBA.SPARQL_DESC_DICT (subj_dict, consts, good_graphs, bad_graphs, storage_name, options);
  if (is_http_ctx ())
    {
      subjs := dict_to_vector (subj_dict, 0);
      for (declare i int, i := 0; i < length (subjs); i := i + 2) 
      {
	declare s any;
	s := subjs [i];
	dict_put (res, vector (iri_to_id (HTTP_URL_HANDLER ()), iri_to_id ('http://xmlns.com/foaf/0.1/primaryTopic'), s), 1);
	dict_put (res, vector (iri_to_id (HTTP_URL_HANDLER ()), iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type'), iri_to_id ('http://xmlns.com/foaf/0.1/Document')), 1);
      }
    }
  return res;
}
;

grant execute on DB.DBA.SPARQL_DESC_DICT_DBPEDIA_PHYSICAL to "SPARQL_SELECT";

--# Facet browser on non-default vd
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/fct');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/fct/service');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/fct/soap');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/services/rdf/iriautocomplete.get');
DB.DBA.VHOST_REMOVE ( lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), lpath=>'/describe');

DB.DBA.VHOST_DEFINE (lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'), 
    lpath=>'/fct', ppath=>'/DAV/VAD/fct/', 
    is_dav=>1, def_page=>'facet.vsp', vsp_user=>'dba', ses_vars=>0, is_default_host=>0);


DB.DBA.VHOST_DEFINE (lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/fct/service', ppath=>'/SOAP/Http/fct_svc',
	 is_dav=>0, soap_user=>'dba', ses_vars=>0, is_default_host=>0);
    
DB.DBA.VHOST_DEFINE (lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/fct/soap', ppath=>'/SOAP/',
	 is_dav=>0, soap_user=>'dba', ses_vars=>0, is_default_host=>0);

DB.DBA.VHOST_DEFINE (lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/services/rdf/iriautocomplete.get', ppath=>'/SOAP/Http/IRI_AUTOCOMPLETE',
	 is_dav=>0, soap_user=>'PROXY', ses_vars=>0, is_default_host=>0);

DB.DBA.VHOST_DEFINE (lhost=>registry_get ('dbp_lhost'), vhost=>registry_get ('dbp_vhost'),
	 lpath=>'/describe', ppath=>'/SOAP/Http/EXT_HTTP_PROXY_1',
	 is_dav=>0, soap_user=>'PROXY', ses_vars=>0,
	 opts=>vector ('url_rewrite', 'ext_fctabout_http_proxy_rule_list1'),
	 is_default_host=>0);

-- VoID VDs
DB.DBA.VHOST_REMOVE (lpath=>'/void/data');
DB.DBA.VHOST_DEFINE (lpath=>'/void/data', ppath=>registry_get('_dbpedia_path_'), is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 vsp_user=>'dba', opts=>vector ('url_rewrite', 'dbpl_void_data_rule_list'));

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbpl_void_data_rule_list', 1, vector ('dbpl_void_data_rule_1'));
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_data_rule_1', 1, '/void/data/(.*)\\.(n3|rdf|ttl)', vector ('par_1', 'fmt'), 1,
'/sparql?default-graph-uri='||registry_get('dbp_graph_decoded')||'%%2Fvoid%%2F&query='||dbp_gen_describe('void')||'&format=%U',
vector ('par_1', 'par_1', 'par_1', 'par_1', 'par_1', 'par_1', 'fmt'), NULL, NULL, 2, null, '');

-- HTML
DB.DBA.VHOST_REMOVE (lpath=>'/void/page');
DB.DBA.VHOST_DEFINE (lpath=>'/void/page', ppath=>registry_get('_dbpedia_path_'), is_dav=>atoi (registry_get('_dbpedia_dav_')),
	 opts=>vector ('url_rewrite', 'dbpl_void_page_rule_list'));

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbpl_void_page_rule_list', 1, vector ('dbpl_void_page_rule_1'));
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_page_rule_1', 1, '/void/page/(.*)', vector ('par_1'), 1,
registry_get('_dbpedia_path_')||'description.vsp?res=%%2Fvoid%%2F%U', vector ('par_1'), NULL, NULL, 0, 0, '');


-- IRIs
DB.DBA.VHOST_REMOVE (lpath=>'/void');
DB.DBA.VHOST_DEFINE (lpath=>'/void', ppath=>'/', is_dav=>0, def_page=>'', opts=>vector ('url_rewrite', 'dbpl_void_rule_list'));

DB.DBA.URLREWRITE_CREATE_RULELIST ( 'dbpl_void_rule_list', 1,
    vector ('dbpl_void_rule_1', 'dbpl_void_rule_2', 'dbpl_void_rule_3', 'dbpl_void_rule_4'));
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_rule_1', 1, '/void/(.*)\x24', vector ('par_1'), 1,
    '/void/page/%s', vector ('par_1'), NULL, NULL, 2, 303, NULL);
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_rule_2', 1, '/void/(.*)\x24', vector ('par_1'), 1,
    '/void/data/%s.rdf', vector ('par_1'), NULL, 'application/rdf.xml', 2, 303, 'Content-Type: application/rdf+xml');
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_rule_3', 1, '/void/(.*)\x24', vector ('par_1'), 1,
    '/void/data/%s.n3', vector ('par_1'), NULL, 'text/rdf.n3', 2, 303, 'Content-Type: text/rdf+n3');
DB.DBA.URLREWRITE_CREATE_REGEX_RULE ( 'dbpl_void_rule_4', 1, '/void/(.*)\x24', vector ('par_1'), 1,
    '/void/data/%s.n3', vector ('par_1'), NULL, 'application/x-turtle', 2, 303, 'Content-Type: application/x-turtle');

TTLP (
'
@prefix owl: <http://www.w3.org/2002/07/owl#> .

<http://dbpedia.org/ontology/deathPlace> owl:equivalentProperty <http://dbpedia.org/property/deathPlace> .
<http://dbpedia.org/ontology/deathDate> owl:equivalentProperty <http://dbpedia.org/property/death> .
<http://dbpedia.org/ontology/birthPlace> owl:equivalentProperty <http://dbpedia.org/property/birthPlace> .
<http://dbpedia.org/ontology/birthDate> owl:equivalentProperty <http://dbpedia.org/property/birth> .
<http://xmlns.com/foaf/0.1/givenName> owl:equivalentProperty <http://xmlns.com/foaf/0.1/givenname> .
<http://purl.org/dc/terms/subject> owl:equivalentProperty <http://www.w3.org/2004/02/skos/core#subject> .
<http://dbpedia.org/ontology/wikiPageID> owl:equivalentProperty <http://dbpedia.org/property/pageId> .
<http://dbpedia.org/ontology/wikiPageRevisionID> owl:equivalentProperty <http://dbpedia.org/property/revisionId> .
<http://dbpedia.org/ontology/wikiPageWikiLink> owl:equivalentProperty <http://dbpedia.org/property/wikilink> .
<http://dbpedia.org/ontology/wikiPageExternalLink> owl:equivalentProperty <http://dbpedia.org/property/reference> .
<http://dbpedia.org/ontology/wikiPageRedirects> owl:equivalentProperty <http://dbpedia.org/property/redirect> .
<http://dbpedia.org/ontology/wikiPageDisambiguates> owl:equivalentProperty <http://dbpedia.org/property/disambiguates> .
', '', 'http://dbpedia.org/schema/property_rules#');

create procedure WS.WS."/!advanced-sparql/" (inout path varchar, inout params any, inout lines any)
{
	  declare query, full_query, format, should_sponge, debug, def_qry varchar;
	  declare dflt_graphs, named_graphs any;
	  declare paramctr, paramcount, qry_params, maxrows, can_sponge, start_time integer;
	  declare ses, content any;
	  declare def_max, add_http_headers, hard_timeout, timeout, client_supports_partial_res, sp_ini, soap_ver int;
	  declare http_meth, content_type, ini_dflt_graph, get_user, jsonp_callback varchar;
	  declare state, msg varchar;
	  declare metas, rset any;
	  declare accept, soap_action, user_id varchar;
	  declare exec_time, exec_db_activity any;
	  -- dbg_obj_princ (path, params, lines);
	  if (registry_get ('__sparql_endpoint_debug') = '1')
	    {
	      for (declare i int, i := 0; i < length (params); i := i + 2)
	        {
		  if (isstring (params[i+1]))
		    dbg_printf ('%s=%s',params[i],params[i+1]);
		  else if (__tag (params[i+1]) = 185)
		    dbg_printf ('%s=%s',params[i],'<strses>');
		  else
		    dbg_printf ('%s=%s',params[i],'<box>');
		}
	    }

	  set http_charset='utf-8';
	  http_methods_set ('OPTIONS', 'GET', 'HEAD', 'POST', 'TRACE');
	  ses := 0;
	  query := null;
	  format := '';
	  should_sponge := '';
	  debug := get_keyword ('debug', params, case (get_keyword ('query', params, '')) when '' then '1' else '' end);
	  add_http_headers := 1;
	  sp_ini := 0;
	  dflt_graphs := vector ();
	  named_graphs := vector ();
	  maxrows := 1024*1024; -- More than enough for web-interface.
	  http_meth := http_request_get ('REQUEST_METHOD');
	  ini_dflt_graph := cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'DefaultGraph');
	  hard_timeout := atoi (coalesce (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'MaxQueryExecutionTime'), '0')) * 1000;
	  timeout := atoi (coalesce (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'ExecutionTimeout'), '0')) * 1000;
	  client_supports_partial_res := 0;
	  def_qry := cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'DefaultQuery');
	  if (def_qry is null)
	    def_qry := 'SELECT * WHERE {?s ?p ?o}';
	  def_max := atoi (coalesce (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'ResultSetMaxRows'), '-1'));
	  -- if timeout specified and it's over 1 second
	  user_id := connection_get ('SPARQLUserId', 'SPARQL');
	  get_user := '';
	  soap_ver := 0;
	  soap_action := http_request_header (lines, 'SOAPAction', null, null);
	  content_type := http_request_header (lines, 'Content-Type', null, '');

	  if (content_type = 'application/soap+xml')
	    soap_ver := 12;
	  else if (soap_action is not null)
	    soap_ver := 11;

	  content := null;
	  can_sponge := coalesce ((select top 1 1
	      from DB.DBA.SYS_USERS as sup
	        join DB.DBA.SYS_ROLE_GRANTS as g on (sup.U_ID = g.GI_SUPER)
	        join DB.DBA.SYS_USERS as sub on (g.GI_SUB = sub.U_ID)
	      where sup.U_NAME = 'SPARQL' and sub.U_NAME = 'SPARQL_SPONGE' ), 0);
	  declare exit handler for sqlstate '*' {
	    DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
	      '500', 'SPARQL Request Failed',
	      query, __SQL_STATE, __SQL_MESSAGE, format);
	     return;
	   };

	  -- the WSDL
	  if (http_path () = '/sparql/services.wsdl')
	    {
	      http_header ('Content-Type: application/wsdl+xml\r\n');
	--      http_header ('Content-Type: text/xml\r\n');
	      DB.DBA.SPARQL_WSDL (lines);
	      return;
	    }
	  else if (http_path () = '/sparql/services11.wsdl')
	    {
	      http_header ('Content-Type: text/xml\r\n');
	      DB.DBA.SPARQL_WSDL11 (lines);
	      return;
	    }

	  paramcount := length (params);
	  if (((0 = paramcount) or ((2 = paramcount) and ('Content' = params[0]))) and soap_ver = 0)
	    {
	       declare redir varchar;
	       redir := registry_get ('WS.WS.SPARQL_DEFAULT_REDIRECT');
	       if (isstring (redir))
	         {
	            http_request_status ('HTTP/1.1 301 Moved Permanently');
	            http_header (sprintf ('Location: %s\r\n', redir));
	            return;
	         }

http('<?xml version="1.0" encoding="UTF-8"?>\n');
http('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n');
http('<html xmlns="http://www.w3.org/1999/xhtml"\n');
http('      xmlns:svg="http://www.w3.org/2000/svg">\n');
http('    <head>\n');
http('        <title>SPARQL Query Form</title>\n');
http('        <meta http-equiv="Content-Type" content="xhtml/xml; charset=UTF-8" />\n');
http('        <!--link type="text/css" rel="stylesheet" href="http://sindice.com/stylesheets/site.css"/-->\n');
http('\n');
http('		<link href="http://fonts.googleapis.com/css?family=Droid+Sans+Mono" rel="stylesheet" type="text/css">\n');
http('        <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/start/jquery-ui.css" media="screen" rel="stylesheet" type="text/css" />\n');
http('\n');
http('        <style type="text/css">\n');
http('        body { font-family: "Droid Sans Mono", sans-serif; font-size: 9pt; color: #234; }\n');
http('        label.n { display: inline; margin-top: 10pt; }\n');
http('        fieldset { \n');
http('            margin:10px 10px 10px 10px; padding:10px; border: 1px solid #779125;\n');
http('            -moz-border-radius: 10px; border-radius: 10px;\n');
http('        }\n');
http('        legend { color: #2D8FB4; }\n');
http('        label { font-weight: bold; }\n');
http('        h1 { width: 100%; background-color: #86b9d9; font-size: 18pt; font-weight: normal; color: #fff; height: 4ex; text-align: right; vertical-align: middle; padding-right:  8px; }\n');
http('        textarea { width: 100%; padding: 3px; }\n');
http('        .fixedWidth{width:auto !important;}\n');
http('        .documentation{\n');
http('        overflow: auto; height:491px;\n');
http('        }\n');
http('        .documentation h2{\n');
http('            margin-top:8px;\n');
http('        }\n');
http('        .documentation h3{\n');
http('            margin-top:4px;\n');
http('        }\n');
http('        .documentation pre{\n');
http('            font-style: italic;\n');
http('        }\n');
http('        .query-footer a {\n');
http('           text-decoration: none;\n');
http('        }\n');
http('        </style>\n');
http('        <script type="text/javascript" src="http://code.jquery.com/jquery-1.7.1.min.js"></script>\n');
http('        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>\n');
http('  \n');
http('        <script language="JavaScript" type="text/javascript">\n');
http('var last_format = 1;\n');
http('function format_select(query_obg)\n');
http('{\n');
http('  var query = query_obg.value; \n');
http('  var format = query_obg.form.format;\n');
http('\n');
http('  if ((query.match(/construct/i) || query.match(/describe/i)) && last_format == 1) {\n');
http('    for(var i = format.options.length; i > 0; i--)\n');
http('      format.options[i] = null;    format.options[1] = new Option(\'N3/Turtle\',\'text/rdf+n3\');\n');
http('    format.options[2] = new Option(\'JSON\',\'application/rdf+json\');\n');
http('    format.options[3] = new Option(\'RDF/XML\',\'application/rdf+xml\');\n');
http('    format.options[4] = new Option(\'NTriples\',\'text/plain\');\n');
http('    format.options[5] = new Option(\'XHTML+RDFa\',\'application/xhtml+xml\');\n');
http('    format.selectedIndex = 1;\n');
http('    last_format = 2;\n');
http('  }\n');
http('\n');
http('  if (!(query.match(/construct/i) || query.match(/describe/i)) && last_format == 2) {\n');
http('    for(var i = format.options.length; i > 0; i--)\n');
http('      format.options[i] = null;\n');
http('    format.options[1] = new Option(\'HTML\',\'text/html\');\n');
http('    format.options[2] = new Option(\'Spreadsheet\',\'application/vnd.ms-excel\');\n');
http('    format.options[3] = new Option(\'XML\',\'application/sparql-results+xml\');\n');
http('    format.options[4] = new Option(\'JSON\',\'application/sparql-results+json\');\n');
http('    format.options[5] = new Option(\'Javascript\',\'application/javascript\');\n');
http('    format.options[6] = new Option(\'N3/Turtle\',\'text/rdf+n3\');\n');
http('    format.options[7] = new Option(\'RDF/XML\',\'application/rdf+xml\');\n');
http('    format.options[8] = new Option(\'NTriples\',\'text/plain\');\n');
http('    format.selectedIndex = 1;\n');
http('    last_format = 1;\n');
http('  }\n');
http('}\n');
http('\n');
http('function createCookie(name,value,days,path) {\n');
http('    var expires = "";\n');
http('    var pathValue ="/";\n');
http('    if(path){\n');
http('        pathValue = path;\n');
http('    }\n');
http('    if (days) {\n');
http('        var date = new Date();\n');
http('        date.setTime(date.getTime()+(days*24*60*60*1000));\n');
http('        expires = "; expires="+date.toGMTString();\n');
http('    }\n');
http('    document.cookie = name+"="+value+expires+"; path="+pathValue;\n');
http('}\n');
http('\n');
http('function readCookie(name) {\n');
http('    var nameEQ = name + "=";\n');
http('    var ca = document.cookie.split(";");\n');
http('    for(var i=0;i < ca.length;i++) {\n');
http('        var c = ca[i];\n');
http('        while (c.charAt(0)==" ") c = c.substring(1,c.length);\n');
http('        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);\n');
http('    }\n');
http('    return null;\n');
http('}\n');
http('\n');
http('function copyToTextarea(t){\n');
http('    document.getElementById("query").value=t;\n');
http('}\n');
http('\n');
http('function loadQuery(queryId) {\n');
http('   var \$target = \$("#example_queries #" + queryId);\n');
http('   if(\$target == undefined) return;\n');
http('   \$target.attr("selected", "selected");\n');
http('   copyToTextarea( \$target.attr("value") );\n');
http('}\n');
http('\n');
http('function showDialog() {\n');
http('    jQuery("#dialog").dialog({\n');
http('        modal: true,\n');
http('        autoopen:true,\n');
http('        width:500,\n');
http('        buttons: {\n');
http('            "Ok, I understood": function() {\n');
http('                \$( this ).dialog( "close" );\n');
http('            }\n');
http('        }\n');
http('    });\n');
http('}\n');
http('\n');
http('cookie = "spaziodati-cookie";\n');
http('\n');
http('jQuery(document).ready(function() {\n');
http('            var c = readCookie(cookie);\n');
http('            if(c==null) {\n');
http('                createCookie(cookie, true, null, "/");\n');
http('                showDialog();\n');
http('            }\n');
http('            parts = window.location.href.split("#");\n');
http('            if(parts.length == 2) loadQuery(parts[1]);\n');
http('});\n');
http('    </script>\n');
http('\n');
http('</head>\n');
http('    <body>\n');
http('            <div id="header" style="position:relative" class="container fixedWidth">\n');
http('                <div class="columnR span-8a last" style="padding:5px">\n');
http('                    <a href="http://it.dbpedia.org">Home</a>\n');
http('                    <a href="http://it.dbpedia.org/sparql?nsdecl">Namespace Prefixes</a>\n');
http('                    <a href="http://it.dbpedia.org/sparql?rdfinf">Inference rules</a>\n');
http('                    </ul>\n');
http('                </div>\n');
http('                <div class="columnL span-3">\n');
http('                    <a href="/"><img src="/files/Logo-DBpedia-Italia-small.png" height="100" alt="DBpedia Italy"/></a>\n');
http('                    <!-- /column -->\n');
http('                </div>\n');
http('                <!-- /header -->\n');
http('            </div>\n');
http('            <div id="main" class="container fixedWidth" >\n');
http('            <table width="100%" height="70%">\n');
http('                <tr>\n');
http('                <td>\n');
http('                <fieldset>\n');
http('                    <legend>Sparql query examples:</legend>\n');
http('<select id="example_queries" onchange="copyToTextarea(this.options[this.selectedIndex].value);">\n');
http('<option value="----">----</option>\n');
http('\n');
http('\n');
http('<!-- BEGIN: predefined queries. -->\n');
http('\n');
http('<option id="qa" value=\'SELECT * WHERE {\n');
http(' ?movie a <http://dbpedia.org/ontology/Film> .\n');
http(' ?movie <http://dbpedia.org/ontology/country> <http://it.dbpedia.org/resource/Italia> .\n');
http('}\'>All Italian produced movies</option>\n');
http('\n');
http('<option id="qb" value=\'SELECT * WHERE {\n');
http(' ?movie a                                            <http://dbpedia.org/ontology/Film> .\n');
http(' ?movie <http://dbpedia.org/ontology/country>        <http://it.dbpedia.org/resource/Italia> .\n');
http(' ?movie <http://dbpedia.org/ontology/filmColourType> ?colour .\n');
http(' FILTER ( ?colour in ("B/N"@it, "bianco/nero"@it ) )\n');
http('}\'>All Italian produced B/W movies</option>\n');
http('\n');
http('<option id="qc" value=\'SELECT * WHERE {\n');
http(' ?movie a                                            <http://dbpedia.org/ontology/Film> .\n');
http(' ?movie <http://dbpedia.org/ontology/country>        <http://it.dbpedia.org/resource/Italia> .\n');
http(' ?movie <http://dbpedia.org/ontology/filmColourType> ?colour .\n');
http(' ?movie <http://dbpedia.org/ontology/musicComposer>  ?composer .\n');
http(' FILTER ( ?colour in ("B/N"@it, "bianco/nero"@it ) )\n');
http('}\'>All music composers for Italian produced B/W movie soundtracks</option>\n');
http('\n');
http('<option id="qd" value=\'SELECT * WHERE {\n');
http(' ?movie a                                            <http://dbpedia.org/ontology/Film> .\n');
http(' ?movie <http://dbpedia.org/ontology/country>        <http://it.dbpedia.org/resource/Italia> .\n');
http(' ?movie <http://dbpedia.org/ontology/filmColourType> ?colour .\n');
http(' ?movie <http://dbpedia.org/ontology/musicComposer>  ?composer .\n');
http('\n');
http(' ?composer   <http://dbpedia.org/ontology/birthPlace>             ?birthplace .\n');
http(' ?birthplace <http://dbpedia.org/ontology/administrativeDistrict> <http://it.dbpedia.org/resource/Trentino-Alto_Adige> .\n');
http(' ?birthplace <http://dbpedia.org/ontology/populationTotal>        ?population\n');
http(' FILTER ( ?colour in ("B/N"@it, "bianco/nero"@it) AND ?population < 40000 )\n');
http('}\'>All music composers for Italian produced B/W movie soundtracks born is a TrentinoAltoAdige City with less than 40k inhabitants</option>\n');
http('\n');
http('<option id="q1" value=\'SELECT ?name, ?surname WHERE {\n');
http('  ?person a <http://dbpedia.org/ontology/Person> . \n');
http('  ?person   <http://it.dbpedia.org/property/nome>    ?name .\n');
http('  ?person   <http://it.dbpedia.org/property/cognome> ?surname .\n');
http('  ?person   <http://it.dbpedia.org/property/nazionalità> "italiana"@it .\n');
http('  FILTER( isLiteral(?name) AND isLiteral(?surname) )\n');
http('}\'>Give me all Italian people in DBPedia</option>\n');
http('\n');
http('<option id="q2" value=\'SELECT ?name, ?surname WHERE {\n');
http('  ?person a <http://dbpedia.org/ontology/Person> .\n');
http('  ?person   <http://it.dbpedia.org/property/nome>     ?name .\n');
http('  ?person   <http://it.dbpedia.org/property/cognome>  ?surname .\n');
http('  ?person   <http://it.dbpedia.org/property/nazionalità> "italiana"@it .\n');
http('  ?person   <http://it.dbpedia.org/property/attività> "artista"@it\n');
http('  FILTER( isLiteral(?name) AND isLiteral(?surname) )\n');
http('}\'>Give me name and surname of all Italian artists in DBpedia</option>\n');
http('\n');
http('<option id="q3" value=\'SELECT ?name, ?surname WHERE {\n');
http('  ?person a <http://dbpedia.org/ontology/Person> .\n');
http('  ?person   <http://it.dbpedia.org/property/nome>     ?name .\n');
http('  ?person   <http://it.dbpedia.org/property/cognome>  ?surname .\n');
http('  ?person   <http://it.dbpedia.org/property/nazionalità> "italiana"@it .\n');
http('  ?person   <http://it.dbpedia.org/property/attività> "artista"@it .\n');
http('  ?person   <http://it.dbpedia.org/property/sesso>    "F"@it .\n');
http('  ?person   <http://dbpedia.org/ontology/birthYear>   ?birth .\n');
http('  FILTER( isLiteral(?name) AND isLiteral(?surname) AND ?birth >= "1972-01-01"^^xsd:date)\n');
http('}\'>Give me name and surname of all Italian artists in DBpedia of gender female born after the 1972</option>\n');
http('\n');
http('<option id="q4" value=\'SELECT * WHERE { \n');
http('  ?person a <http://dbpedia.org/ontology/Person> .\n');
http('  ?person   <http://it.dbpedia.org/property/nome>     ?name .\n');
http('  ?person   <http://it.dbpedia.org/property/cognome>  ?surname .\n');
http('  ?person   <http://it.dbpedia.org/property/nazionalità> "italiana"@it .\n');
http('  ?person   <http://it.dbpedia.org/property/attività> "artista"@it .\n');
http('  ?person   <http://it.dbpedia.org/property/sesso>    "F"@it .\n');
http('  ?person   <http://dbpedia.org/ontology/birthYear>   ?birth .\n');
http('  ?person   <http://dbpedia.org/ontology/birthPlace>  ?city .\n');
http('\n');
http('  ?city a                                             <http://dbpedia.org/ontology/PopulatedPlace> .\n');
http('  ?city rdfs:label                                    ?birthplace .\n');
http('  ?city <http://dbpedia.org/ontology/populationTotal> ?population\n');
http('\n');
http('  FILTER( isLiteral(?name) AND isLiteral(?surname) AND ?birth >= "1972-01-01"^^xsd:date AND ?population < 40000)\n');
http('}\'>Give me personal data of all Italian artists in DBpedia of gender female born after 1972 in a city with population lesser than 40k inhabitants</option>\n');
http('\n');
http('<option id="q5" value=\'SELECT str(?surname), ?p WHERE {\n');
http('  ?p a <http://dbpedia.org/ontology/Person> . \n');
http('  ?p <http://it.dbpedia.org/property/attività> "scrittore"@it .\n');
http('  ?p <http://it.dbpedia.org/property/attività> "archeologo"@it .\n');
http('  ?p <http://it.dbpedia.org/property/epoca>    "1900"^^xsd:int .\n');
http('  ?p <http://xmlns.com/foaf/0.1/surname>       ?surname\n');
http('  FILTER( strlen(?surname) = 6 )\n');
http('}\'>Give me the surname of an archeologist that has been also a writer lived in 19th century which the surname is exactly 6 letters long</option>\n');
http('\n');
http('<!-- END: predefined queries. -->\n');
http('\n');
http('</select>\n');
http('</fieldset>   \n');
http('\n');
http('<form action="http://it.dbpedia.org/sparql" method="GET">\n');
http('            <fieldset>\n');
http('            <legend>Query:</legend>\n');
http('              <label for="default-graph-uri">Default Graph URI</label>\n');
http('              <br />\n');
http('              <input type="text" name="default-graph-uri" id="default-graph-uri" style="border: 1px solid" value="" size="80"/>\n');
http('                <br />\n');
http('              <textarea style="font-family:\'Droid Sans Mono\'" rows="20" cols="80" name="query" id="query" onchange="format_select(this)" onkeyup="format_select(this)"></textarea>\n');
http('              <br /><br />\n');
http('              <label for="format" class="n">Display Results As:</label>\n');
http('              <select name="format">\n');
http('                <option value="auto">Auto</option>\n');
http('                <option value="text/html" selected="selected">HTML</option>\n');
http('                <option value="application/vnd.ms-excel">Spreadsheet</option>\n');
http('                <option value="application/sparql-results+xml">XML</option>\n');
http('                <option value="application/sparql-results+json">JSON</option>\n');
http('                <option value="application/javascript">Javascript</option>\n');
http('                <option value="text/plain">NTriples</option>\n');
http('                <option value="application/rdf+xml">RDF/XML</option>\n');
http('              </select>\n');
http('&nbsp;&nbsp;&nbsp;\n');
http('<input name="debug" type="checkbox" checked/>&nbsp;<label for="debug" class="n"><nobr>Rigorous check of the query</nobr></label>\n');
http('&nbsp;&nbsp;&nbsp;\n');
http('<!-- \n');
http('<input name="timeout" type="text"0/>&nbsp;<label for="timeout" class="n"><nobr>Execution timeout, in milliseconds, values less than 1000 are ignored</nobr></label>\n');
http('&nbsp;&nbsp;&nbsp;\n');
http('-->\n');
http('<input type="submit" value="Run Query"/>&nbsp;<input type="reset" value="Reset"/>&nbsp;<small>(The query results are <a href="#" onclick="showDialog()">limited</a> to <strong>1000</strong> records)</small>\n');
http('</fieldset>\n');
http('</form>\n');
http('\n');
http('            <div style="text-align: center; margin-top: 20px;">\n');
http('               \n');
http('                <span class="query-footer">\n');
http('                <strong>DBpedia Italia</strong>, by <a href="http://spaziodati.eu" target="_blank"><strong>SpazioDati SRL</strong></a> and <a href="http://fbk.eu" target="_blank"><strong>FBK</strong></a>. \n');
http('                Hosted by <strong><a href="http://www.top-ix.org/" target="_blank">Top-ix</a></strong>.\n');
http('                <div style="margin:4px;">\n');
http('                <a href="http://spaziodati.eu" target="_blank"><img width="53" height="32"src="data:image/png;base64,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" /></a>\n');
http('                <a href="http://www.openlinksw.com/" target="_blank"><img height="32px" src="data:image/png;base64,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" /></a>\n');
http('                <!--\n');
http('                <a href="http://www.openlinksw.com/virtuoso/" target="_blank"><img height="32px" src="data:image/png;base64,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%3D%3D" /></a>\n');
http('                -->\n');
http('                </span>\n');
http('                </div>\n');
http('            </div>\n');
http('\n');
http('        </td>\n');
http('        </tr>\n');
http('        </table>\n');
http('        \n');
http('        </div>\n');
http('        \n');
http('        <div style="clear:both;"></div>\n');
http('        \n');
http('        <div id="footer" class="container clear fixedWidth">\n');
http('            <div  class="span-6" style="float:left;">\n');
http('                <p>\n');
http('                    <a href="http://it.dbpedia.org" target="_blank">Home</a> |\n');
http('                    <a href="http://it.dbpedia.org/en/about-en" target="_blank">About</a> |\n');
http('                    <a href="http://it.dbpedia.org/en/about-en" target="_blank">Contact</a> |\n');
http('                    Copyright &copy; 2012 <a href="http://spaziodati.eu" target="_blank">SpazioDati</a>\n');
http('               </p> \n');
http('        </div>\n');
http('        <div style="clear:both;"></div>\n');
http('        <div id="dialog" title="Welcome to the DBpedia Italia SPARQL endpoint" style="display:none;">\n');
http('            <div style="padding:10px;">\n');
http('            <b>Please notice the following:</b>\n');
http('            <ul>\n');
http('            <li>Results provided in the HTML are usually a subset of what you will get by calling programmatically.</li>\n');
http('            <li>All queries are time and resource limited.<b> notice that this means that sometime you will get incomplete or even no results</b>.\n');
http('                If this is happening often for you or you really want to run more complex queries please contact us.</li>\n');
http('            <li>The endpoint is updated monthly so query result can vary in time.</li>\n');
http('            <li>This service is beta.<b>Please help us by providing feedback on our <a href="info@spaziodati.eu">email</a></b>. We\'ll be looking forward to hear from you.</li>\n');
http('          </ul>\n');
http('            <br/>\n');
http('            Enjoy!\n');
http('            </div>\n');
http('        </div>\n');
http('        <script>');
http('            var _gaq = _gaq || [];_gaq.push(["_setAccount", "UA-27344094-2"]);');
http('            _gaq.push(["_trackPageview"]);');
http('             (function() {var ga = document.createElement("script");');
http('                 ga.type = "text/javascript";ga.async = true;');
http('                 ga.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";');
http('                 var s = document.getElementsByTagName("script")[0];s.parentNode.insertBefore(ga, s);');
http('             })();');
http('        </script>');
http('    </body>\n');
http('</html>\n');

       return;
    }
  qry_params := dict_new (7);
  for (paramctr := 0; paramctr < paramcount; paramctr := paramctr + 2)
    {
      declare pname, pvalue varchar;
      pname := params [paramctr];
      pvalue := params [paramctr+1];
      if ('query' = pname)
        query := pvalue;
      else if ('find' = pname)
	{
	  declare cls, words, ft, vec, cond varchar;
	  cls := get_keyword ('class', params);
	  maxrows := atoi (get_keyword ('maxrows', params, cast (maxrows as varchar)));
	  if (def_max > 0 and def_max < maxrows)
	    maxrows := def_max;
	  if (cls is not null)
	    cond := sprintf (' ?s a %s . ', cls);
          else
	    cond := '';
	  ft := trim (DB.DBA.FTI_MAKE_SEARCH_STRING_INNER (pvalue, words), '()');
          if (ft is null or length (words) = 0)
            {
              DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
                '400', 'Bad Request',
                query, '22023', 'The value of "find" parameter of web service endpoint is not a valid search string' );
              return;
            }
	  vec := DB.DBA.SYS_SQL_VECTOR_PRINT (words);
	  if (get_keyword ('format', params, '') like '%/rdf+%' or http_request_header (lines, 'Accept', null, '') like '%/rdf+%')
	    query := sprintf ('construct { ?s ?p `bif:search_excerpt (bif:vector (%s), sql:rdf_find_str(?o))` } ' ||
	    'where { ?s ?p ?o . %s filter (bif:contains (?o, ''%s'')) } limit %d', vec, cond, ft, maxrows);
	  else
	    query := sprintf ('select ?s ?p (bif:search_excerpt (bif:vector (%s), sql:rdf_find_str(?o))) ' ||
	    'where { ?s ?p ?o . %s filter (bif:contains (?o, ''%s'')) } limit %d', vec, cond, ft, maxrows);
	}
      else if ('default-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, dflt_graphs) <= 0)
	    dflt_graphs := vector_concat (dflt_graphs, vector (pvalue));
	}
      else if ('named-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, named_graphs) <= 0)
	    named_graphs := vector_concat (named_graphs, vector (pvalue));
	}
      else if ('maxrows' = pname)
        {
	  maxrows := cast (pvalue as integer);
	}
      else if ('should-sponge' = pname)
        {
          if (can_sponge)
            should_sponge := trim(pvalue);
	}
      else if ('format' = pname or 'output' = pname)
        {
	  format := pvalue;
	}
      else if ('timeout' = pname)
        {
          declare t integer;
          t := cast (pvalue as integer) * 1000;
          if (t is not null and t >= 1000)
            {
              if (hard_timeout >= 1000)
                timeout := __min (t, hard_timeout);
              else
                timeout := t;
            }
          client_supports_partial_res := 1;
	}
      else if ('ini' = pname)
        {
	  sp_ini := 1;
	}
      else if (query is null and 'query-uri' = pname and length (pvalue))
	{
	  if (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'ExternalQuerySource') = '1')
	    {
	      declare uri varchar;
	      declare hf, hdr, charset any;
	      uri := pvalue;
	      if (uri like 'http://%' and uri not like 'http://localdav.virt/%' and uri not like 'http://local.virt/dav/%')
		{
		  query := http_get (uri, hdr);
		  if (hdr[0] not like '% 200%')
		    signal ('22023', concat ('HTTP request failed: ', hdr[0], 'for URI ', uri));
		  charset := http_request_header (hdr, 'Content-Type', 'charset', '');
		  if (charset <> '')
		    {
		      query := charset_recode (query, charset, 'UTF-8');
		    }
		}
	      else
		{
		  query := DB.DBA.XML_URI_GET ('', pvalue);
	        }
	    }
	  else
	    {
	       DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
		    '403', 'Prohibited', query, '22023', 'The external query sources are prohibited.');
	       return;
	    }
	}
      else if ('xslt-uri' = pname and length (pvalue))
	{
	  if (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'ExternalXsltSource') = '1')
	    {
	      add_http_headers := 0;
	      http_xslt (pvalue);
	    }
	  else
	    {
	       DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
		    '403', 'Prohibited', query, '22023', 'The XSL-T transformation is prohibited');
	       return;
	    }
	}
      else if ('get-login' = pname)
	{
	  get_user := pvalue;
	}
      else if ('callback' = pname)
        {
          jsonp_callback := pvalue;
        }
      else if (pname[0] = '?'[0])
        {
          dict_put (qry_params, subseq (pname, 1), pvalue);
        }
    }
  if (format <> '')
  {
    format := (
      case lower(format)
        when 'json' then 'application/sparql-results+json'
        when 'js' then 'application/javascript'
        when 'html' then 'text/html'
        when 'sparql' then 'application/sparql-results+xml'
        when 'xml' then 'application/sparql-results+xml'
        when 'rdf' then 'application/rdf+xml'
        when 'n3' then 'text/rdf+n3'
        else format
      end);
  }

  if (def_max > 0 and def_max < maxrows)
    maxrows := def_max;

  --if (0 = length (dflt_graphs) and length (ini_dflt_graph))
  --  dflt_graphs := vector (ini_dflt_graph);


  -- SOAP 1.2 operation begins
  if (http_meth = 'POST' and soap_ver > 0)
    {
       declare xt, dgs, ngs any;
       declare soap_ns, spt_ns, ns_decl varchar;
       soap_ns := DB.DBA.SPARQL_SOAP_NS (soap_ver);
       spt_ns := DB.DBA.SPARQL_PT_NS ();
       ns_decl := '[ xmlns:soap="'||soap_ns||'" xmlns:sp="'||spt_ns||'" ] ';
       content := http_body_read ();
       if (registry_get ('__sparql_endpoint_debug') = '1')
         dbg_printf ('content=[%s]', string_output_string (content));
       xt := xtree_doc (content);
       query := charset_recode (xpath_eval (ns_decl||'string (/soap:Envelope/soap:Body/sp:query-request/query)', xt), '_WIDE_', 'UTF-8');
       dgs := xpath_eval (ns_decl||'/soap:Envelope/soap:Body/sp:query-request/default-graph-uri', xt, 0);
       ngs := xpath_eval (ns_decl||'/soap:Envelope/soap:Body/sp:query-request/named-graph-uri', xt, 0);
       foreach (any frag in dgs) do
	 {
	   declare pvalue varchar;
	   pvalue := charset_recode (xpath_eval ('string(.)', frag), '_WIDE_', 'UTF-8');
	   if (position (pvalue, dflt_graphs) <= 0)
	     dflt_graphs := vector_concat (dflt_graphs, vector (pvalue));
	 }
       foreach (any frag in ngs) do
	 {
	   declare pvalue varchar;
	   pvalue := charset_recode (xpath_eval ('string(.)', frag), '_WIDE_', 'UTF-8');
	   if (position (pvalue, named_graphs) <= 0)
	     named_graphs := vector_concat (named_graphs, vector (pvalue));
	 }
       format := sprintf('application/soap+xml;%d', soap_ver);
    }
  if (format <> '')
    accept := format;
  else
    accept := http_request_header (lines, 'Accept', null, '');
  if (sp_ini)
    {
      SPARQL_INI_PARAMS (metas, rset);
      goto write_results;
    }

  if (query is null)
    {
      if (strstr (content_type, 'application/xml') is not null)
        {
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '400', 'Bad Request',
	    query, '22023', 'XML notation of SPARQL queries is not supported' );
	  return;
	}
      DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
        '400', 'Bad Request',
        query, '22023', 'The request does not contain text of SPARQL query', format);
      return;
    }

  full_query := query;
  -- dbg_obj_princ ('dflt_graphs = ', dflt_graphs, ', named_graphs = ', named_graphs);
  declare req_hosts varchar;
  declare req_hosts_split any;
  declare hctr integer;
  req_hosts := http_request_header (lines, 'Host', null, null);
  req_hosts := replace (req_hosts, ', ', ',');
  req_hosts_split := split_and_decode (req_hosts, 0, '\0\0,');
  for (hctr := length (req_hosts_split) - 1; hctr >= 0; hctr := hctr - 1)
    {
      for (select top 1 SH_GRAPH_URI, SH_DEFINES from DB.DBA.SYS_SPARQL_HOST
      where req_hosts_split [hctr] like SH_HOST) do
        {
          if (length (dflt_graphs) = 0 and length (SH_GRAPH_URI))
            dflt_graphs := vector (SH_GRAPH_URI);
          if (SH_DEFINES is not null)
            full_query := concat (SH_DEFINES, ' ', full_query);
          goto host_found;
        }
    }
host_found:

  foreach (varchar dg in dflt_graphs) do
    {
      full_query := concat ('define input:default-graph-uri <', dg, '> ', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-default-graph: %s\r\n', dg));
    }
  foreach (varchar ng in named_graphs) do
    {
      full_query := concat ('define input:named-graph-uri <', ng, '> ', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-named-graph: %s\r\n', ng));
    }
  if ((should_sponge = 'soft') or (should_sponge = 'replacing'))
    full_query := concat (sprintf('define get:soft "%s" ',should_sponge), full_query);
  else if (should_sponge = 'grab-all')
    full_query := concat ('define input:grab-all "yes" define input:grab-depth 5 define input:grab-limit 100 ', full_query);
  else if (should_sponge = 'grab-all-seealso')
    full_query := concat ('define input:grab-all "yes" define input:grab-depth 5 define input:grab-limit 200 define input:grab-seealso <http://www.w3.org/2000/01/rdf-schema#seeAlso> define input:grab-seealso <http://xmlns.com/foaf/0.1/seeAlso> ', full_query);
  else if (should_sponge = 'grab-everything')
    full_query := concat ('define input:grab-all "yes" define input:grab-intermediate "yes" define input:grab-depth 5 define input:grab-limit 500 define input:grab-seealso <http://www.w3.org/2000/01/rdf-schema#seeAlso> define input:grab-seealso <http://xmlns.com/foaf/0.1/seeAlso> ', full_query);
--  full_query := concat ('define output:valmode "LONG" ', full_query);
  if (debug <> '')
    full_query := concat ('define sql:signal-void-variables 1 ', full_query);
  if (get_user <> '')
    full_query := concat ('define get:login "', get_user, '" ', full_query);
  if (dict_size (qry_params) > 0)
    {
      declare pnames any;
      pnames := dict_list_keys (qry_params, 0);
      foreach (varchar pname in pnames) do
        {
          full_query := concat ('define sql:param "', pname, '" ', full_query);
        }
      qry_params := DB.DBA.PARSE_SPARQL_WS_PARAMS (dict_to_vector (qry_params, 1));
    }
  else
    qry_params := vector ();
  state := '00000';
  metas := null;
  rset := null;
  if (registry_get ('__sparql_endpoint_debug') = '1')
    dbg_printf ('query=[%s]', full_query);

  declare sc_max int;
  declare sc decimal;
  sc_max := atoi (coalesce (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'MaxQueryCostEstimationTime'), '-1'));
  if (sc_max < 0)
    sc_max := atoi (coalesce (cfg_item_value (virtuoso_ini_path (), 'SPARQL', 'MaxExecutionTime'), '-1'));
  if (sc_max > 0)
    {
      state := '00000';
      sc := exec_score (concat ('sparql ', full_query), state, msg);
      if ((sc/1000) > sc_max)
	{
	  signal ('42000', sprintf ('The estimated execution time %d (sec) exceeds the limit of %d (sec).', sc/1000, sc_max));
	}
    }

  state := '00000';
  metas := null;
  rset := null;

  if (not client_supports_partial_res) -- partial results do not work with chunked encoding
    {
    -- No need to choose accurately if there are no variants.
    -- Disabled due to empty results:
    --  if (strchr (accept, ' ') is null)
    --    {
    --      if (accept='application/sparql-results+xml')
    --        full_query := 'define output:format "HTTP+XML application/sparql-results+xml" ' || full_query;
    ----      else if (accept='application/rdf+xml')
    ----        full_query := 'define output:format "HTTP+RDF/XML application/rdf+xml" ' || full_query;
    --    }
    --  else
    -- No need to choose accurately if there is the best variant.
    -- Disabled due to empty results:
    --    {
          declare fmtxml, fmtttl varchar;
          if (strstr (accept, 'application/sparql-results+xml') is not null)
            fmtxml := '"HTTP+XML application/sparql-results+xml" ';
          if (strstr (accept, 'text/rdf+n3') is not null)
            fmtttl := '"HTTP+TTL text/rdf+n3" ';
          else if (strstr (accept, 'text/rdf+ttl') is not null)
            fmtttl := '"HTTP+TTL text/rdf+ttl" ';
          else if (strstr (accept, 'text/rdf+turtle') is not null)
            fmtttl := '"HTTP+TTL text/rdf+turtle" ';
          else if (strstr (accept, 'text/turtle') is not null)
            fmtttl := '"HTTP+TTL text/turtle" ';
          else if (strstr (accept, 'application/turtle') is not null)
            fmtttl := '"HTTP+TTL application/turtle" ';
          else if (strstr (accept, 'application/x-turtle') is not null)
            fmtttl := '"HTTP+TTL application/x-turtle" ';
          if (isstring (fmtttl))
            {
              if (isstring (fmtxml))
                full_query := 'define output:format ' || fmtxml || 'define output:dict-format ' || fmtttl || full_query;
              else
                full_query := 'define output:format ' || fmtttl || full_query;
            }
    --    }
    ;
    }
  -- dbg_obj_princ ('accept = ', accept);
  -- dbg_obj_princ ('full_query = ', full_query);
  -- dbg_obj_princ ('qry_params = ', qry_params);
  commit work;
  if (client_supports_partial_res and (timeout > 0))
    {
      set RESULT_TIMEOUT = timeout;
      -- dbg_obj_princ ('anytime timeout is set to', timeout);
      set TRANSACTION_TIMEOUT=timeout + 10000;
    }
  else if (hard_timeout >= 1000)
    {
      set TRANSACTION_TIMEOUT=hard_timeout;
    }
  set_user_id (user_id);
  start_time := msec_time();
  exec ( concat ('sparql ', full_query), state, msg, qry_params, vector ('max_rows', maxrows, 'use_cache', 1), metas, rset);
  commit work;
  -- dbg_obj_princ ('exec metas=', metas, ', state=', state, ', msg=', msg);
  if (state = '00000')
    goto write_results;
  if (state = 'S1TAT')
    {
      exec_time := msec_time () - start_time;
      exec_db_activity := db_activity ();
      --reply := xmlelement ("facets", xmlelement ("sparql", qr), xmlelement ("time", msec_time () - start_time),
      --                 xmlelement ("complete", cplete),
      --                 xmlelement ("db-activity", db_activity ()), res[0][0]);
    }
  else
    {
      declare state2, msg2 varchar;
      state2 := '00000';
      exec ('isnull (sparql_to_sql_text (?))', state2, msg2, vector (full_query));
      if (state2 <> '00000')
        {
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '400', 'Bad Request',
            full_query, state2, msg2, format);
          return;
        }
      DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
        '500', 'SPARQL Request Failed',
	full_query, state, msg, format);
      return;
    }
write_results:
  if ((1 <> length (metas[0])) or ('aggret-0' <> metas[0][0][0]))
    {
      declare status any;
      if (isinteger (msg))
        status := NULL;
      else
        status := vector (state, msg, exec_time, exec_db_activity);
      if (isstring (jsonp_callback))
        http (jsonp_callback || '(\n');
      DB.DBA.SPARQL_RESULTS_WRITE (ses, metas, rset, accept, add_http_headers, status);
      if (isstring (jsonp_callback))
        http (')');
    }
}
;

DB.DBA.VHOST_REMOVE (lpath=>'/sparql');
DB.DBA.VHOST_DEFINE (lpath=>'/sparql/', ppath => '/!advanced-sparql/', is_dav => 1, vsp_user => 'dba', opts => vector('noinherit', 1));
grant execute on WS.WS."/!advanced-sparql/" to "SPARQL";
registry_set ('/!advanced-sparql/', 'no_vsp_recompile');
