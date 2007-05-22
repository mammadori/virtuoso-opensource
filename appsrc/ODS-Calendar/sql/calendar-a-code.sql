--
--  $Id$
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2007 OpenLink Software
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
-------------------------------------------------------------------------------
--
-- Session Functions
--
-------------------------------------------------------------------------------
create procedure CAL.WA.session_restore(
  inout params any)
{
  declare aPath, domain_id, user_id, user_name, user_role, sid, realm, options any;

  declare exit handler for sqlstate '*' {
    domain_id := -2;
    goto _end;
  };

  sid := get_keyword ('sid', params, '');
  realm := get_keyword ('realm', params, '');

  options := http_map_get('options');
  if (not is_empty_or_null(options))
    domain_id := get_keyword ('domain', options);
  if (is_empty_or_null (domain_id)) {
    aPath := split_and_decode (trim (http_path (), '/'), 0, '\0\0/');
    domain_id := cast(aPath[1] as integer);
  }
  if (not exists(select 1 from DB.DBA.WA_INSTANCE where WAI_ID = domain_id and domain_id <> -2))
    domain_id := -1;

_end:
  domain_id := cast (domain_id as integer);
  user_id := -1;
  for (select U.U_ID,
              U.U_NAME,
              U.U_FULL_NAME
         from DB.DBA.VSPX_SESSION S,
              WS.WS.SYS_DAV_USER U
        where S.VS_REALM = realm
          and S.VS_SID   = sid
          and S.VS_UID   = U.U_NAME) do
  {
    user_id   := U_ID;
    user_name := CAL.WA.user_name(U_NAME, U_FULL_NAME);
    user_role := CAL.WA.access_role(domain_id, U_ID);
  }
  if ((user_id = -1) and (domain_id >= 0) and (not exists(select 1 from DB.DBA.WA_INSTANCE where WAI_ID = domain_id and WAI_IS_PUBLIC = 1)))
    domain_id := -1;

  if (user_id = -1)
    if (domain_id = -1) {
      user_role := 'expire';
      user_name := 'Expire session';
    } else if (domain_id = -2) {
      user_role := 'public';
      user_name := 'Public User';
    } else {
      user_role := 'guest';
      user_name := 'Guest User';
    }

  return vector('domain_id', domain_id,
                'user_id',   user_id,
                'user_name', user_name,
                'user_role', user_role
               );
}
;

-------------------------------------------------------------------------------
--
-- Freeze Functions
--
-------------------------------------------------------------------------------
create procedure CAL.WA.frozen_check(in domain_id integer)
{
  declare exit handler for not found { return 1; };

  if (is_empty_or_null((select WAI_IS_FROZEN from DB.DBA.WA_INSTANCE where WAI_ID = domain_id)))
    return 0;

  declare user_id integer;

  user_id := (select U_ID from SYS_USERS where U_NAME = connection_get ('vspx_user'));
  if (CAL.WA.check_admin(user_id))
    return 0;

  user_id := (select U_ID from SYS_USERS where U_NAME = connection_get ('owner_user'));
  if (CAL.WA.check_admin(user_id))
    return 0;

  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.frozen_page(in domain_id integer)
{
  return (select WAI_FREEZE_REDIRECT from DB.DBA.WA_INSTANCE where WAI_ID = domain_id);
}
;

-------------------------------------------------------------------------------
--
-- User Functions
--
-------------------------------------------------------------------------------
create procedure CAL.WA.check_admin(
  in user_id integer) returns integer
{
  declare group_id integer;
  group_id := (select U_GROUP from SYS_USERS where U_ID = user_id);

  if (user_id = 0)
    return 1;
  if (user_id = http_dav_uid ())
    return 1;
  if (group_id = 0)
    return 1;
  if (group_id = http_dav_uid ())
    return 1;
  if(group_id = http_dav_uid()+1)
    return 1;
  return 0;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.check_grants(in domain_id integer, in user_id integer, in role_name varchar)
{
  whenever not found goto _end;

  if (CAL.WA.check_admin(user_id))
    return 1;
  if (role_name is null or role_name = '')
    return 0;
  if (role_name = 'admin')
    return 0;
  if (role_name = 'guest') {
    if (exists(select 1
                 from SYS_USERS A,
                      WA_MEMBER B,
                      WA_INSTANCE C
                where A.U_ID = user_id
                  and B.WAM_USER = A.U_ID
                  and B.WAM_INST = C.WAI_NAME
                  and C.WAI_ID = domain_id))
      return 1;
  }
  if (role_name = 'owner')
    if (exists(select 1
                 from SYS_USERS A,
                      WA_MEMBER B,
                      WA_INSTANCE C
                where A.U_ID = user_id
                  and B.WAM_USER = A.U_ID
                  and B.WAM_MEMBER_TYPE = 1
                  and B.WAM_INST = C.WAI_NAME
                  and C.WAI_ID = domain_id))
      return 1;
_end:
  return 0;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.check_grants2(in role_name varchar, in page_name varchar)
{
  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.access_role(in domain_id integer, in user_id integer)
{
  whenever not found goto _end;

  if (CAL.WA.check_admin (user_id))
    return 'admin';

  if (exists(select 1
               from SYS_USERS A,
                    WA_MEMBER B,
                    WA_INSTANCE C
              where A.U_ID = user_id
                and B.WAM_USER = A.U_ID
                and B.WAM_MEMBER_TYPE = 1
                and B.WAM_INST = C.WAI_NAME
                and C.WAI_ID = domain_id))
    return 'owner';

  if (exists(select 1
               from SYS_USERS A,
                    WA_MEMBER B,
                    WA_INSTANCE C
              where A.U_ID = user_id
                and B.WAM_USER = A.U_ID
                and B.WAM_MEMBER_TYPE = 2
                and B.WAM_INST = C.WAI_NAME
                and C.WAI_ID = domain_id))
    return 'author';

  if (exists(select 1
               from SYS_USERS A,
                    WA_MEMBER B,
                    WA_INSTANCE C
              where A.U_ID = user_id
                and B.WAM_USER = A.U_ID
                and B.WAM_INST = C.WAI_NAME
                and C.WAI_ID = domain_id))
    return 'reader';

  if (exists(select 1
               from SYS_USERS A
              where A.U_ID = user_id))
    return 'guest';

_end:
  return 'public';
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.wa_home_link ()
{
  return case when registry_get ('wa_home_link') = 0 then '/ods/' else registry_get ('wa_home_link') end;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.wa_home_title ()
{
  return case when registry_get ('wa_home_title') = 0 then 'ODS Home' else registry_get ('wa_home_title') end;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.page_name ()
{
  declare aPath any;

  aPath := http_path ();
  aPath := split_and_decode (aPath, 0, '\0\0/');
  return aPath [length (aPath) - 1];
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.xslt_root()
{
  declare sHost varchar;

  sHost := cast (registry_get('calendar_path') as varchar);
  if (sHost = '0')
    return 'file://apps/Calendar/xslt/';
  if (isnull (strstr(sHost, '/DAV/VAD')))
    return sprintf ('file://%sxslt/', sHost);
  return sprintf ('virt://WS.WS.SYS_DAV_RES.RES_FULL_PATH.RES_CONTENT:%sxslt/', sHost);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.xslt_full(
  in xslt_file varchar)
{
  return concat(CAL.WA.xslt_root(), xslt_file);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.export_rss_sqlx_int (
  in domain_id integer,
  in account_id integer)
{
  declare retValue any;

  retValue := string_output ();

  http ('<?xml version ="1.0" encoding="UTF-8"?>\n', retValue);
  http ('<rss version="2.0">\n', retValue);
  http ('<channel>\n', retValue);

  http ('<sql:sqlx xmlns:sql="urn:schemas-openlink-com:xml-sql" sql:xsl=""><![CDATA[\n', retValue);
  http ('select \n', retValue);
  http ('  XMLELEMENT(\'title\', CAL.WA.utf2wide(CAL.WA.domain_name (<DOMAIN_ID>))), \n', retValue);
  http ('  XMLELEMENT(\'description\', CAL.WA.utf2wide(CAL.WA.domain_description (<DOMAIN_ID>))), \n', retValue);
  http ('  XMLELEMENT(\'managingEditor\', U_E_MAIL), \n', retValue);
  http ('  XMLELEMENT(\'pubDate\', CAL.WA.dt_rfc1123(now ())), \n', retValue);
  http ('  XMLELEMENT(\'generator\', \'Virtuoso Universal Server \' || sys_stat(\'st_dbms_ver\')), \n', retValue);
  http ('  XMLELEMENT(\'webMaster\', U_E_MAIL), \n', retValue);
  http ('  XMLELEMENT(\'link\', CAL.WA.calendar_url (<DOMAIN_ID>)) \n', retValue);
  http ('from DB.DBA.SYS_USERS where U_ID = <USER_ID> \n', retValue);
  http (']]></sql:sqlx>\n', retValue);

  http ('<sql:sqlx xmlns:sql=\'urn:schemas-openlink-com:xml-sql\'><![CDATA[\n', retValue);
  http ('select \n', retValue);
  http ('  XMLAGG(XMLELEMENT(\'item\', \n', retValue);
  http ('    XMLELEMENT(\'title\', CAL.WA.utf2wide (E_SUBJECT)), \n', retValue);
  http ('    XMLELEMENT(\'description\', CAL.WA.utf2wide (E_DESCRIPTION)), \n', retValue);
  http ('    XMLELEMENT(\'guid\', E_ID), \n', retValue);
  http ('    XMLELEMENT(\'link\', CAL.WA.event_url (<DOMAIN_ID>, E_ID)), \n', retValue);
  http ('    XMLELEMENT(\'pubDate\', CAL.WA.dt_rfc1123 (E_UPDATED)), \n', retValue);
  http ('    (select XMLAGG (XMLELEMENT (\'category\', TV_TAG)) from CAL..TAGS_VIEW where tags = E_TAGS), \n', retValue);
  http ('    XMLELEMENT(\'http://www.openlinksw.com/weblog/:modified\', CAL.WA.dt_iso8601 (E_UPDATED)))) \n', retValue);
  http ('from (select top 15  \n', retValue);
  http ('        E_SUBJECT, \n', retValue);
  http ('        E_DESCRIPTION, \n', retValue);
  http ('        E_UPDATED, \n', retValue);
  http ('        E_TAGS, \n', retValue);
  http ('        E_ID \n', retValue);
  http ('      from \n', retValue);
  http ('        CAL.WA.EVENTS \n', retValue);
  http ('      where E_DOMAIN_ID = <DOMAIN_ID> \n', retValue);
  http ('      order by E_UPDATED desc) x \n', retValue);
  http (']]></sql:sqlx>\n', retValue);

  http ('</channel>\n', retValue);
  http ('</rss>\n', retValue);

  retValue := string_output_string (retValue);
  retValue := replace (retValue, '<USER_ID>', cast (account_id as varchar));
  retValue := replace (retValue, '<DOMAIN_ID>', cast (domain_id as varchar));
  return retValue;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.export_rss_sqlx (
  in domain_id integer,
  in account_id integer)
{
  declare retValue any;

  retValue := CAL.WA.export_rss_sqlx_int (domain_id, account_id);
  return replace (retValue, 'sql:xsl=""', '');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.export_atom_sqlx(
  in domain_id integer,
  in account_id integer)
{
  declare retValue, xsltTemplate any;

  xsltTemplate := CAL.WA.xslt_full ('rss2atom03.xsl');
  if (CAL.WA.settings_atomVersion (CAL.WA.settings (account_id)) = '1.0')
    xsltTemplate := CAL.WA.xslt_full ('rss2atom.xsl');

  retValue := CAL.WA.export_rss_sqlx_int (domain_id, account_id);
  return replace (retValue, 'sql:xsl=""', sprintf ('sql:xsl="%s"', xsltTemplate));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.export_rdf_sqlx (
  in domain_id integer,
  in account_id integer)
{
  declare retValue any;

  retValue := CAL.WA.export_rss_sqlx_int (domain_id, account_id);
  return replace (retValue, 'sql:xsl=""', sprintf ('sql:xsl="%s"', CAL.WA.xslt_full ('rss2rdf.xsl')));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_gems_create (
  inout domain_id integer,
  inout account_id integer)
{
  declare read_perm, exec_perm, content, home, path varchar;

  home := CAL.WA.dav_home(account_id);
  if (isnull (home))
    return;

  read_perm := '110100100N';
  exec_perm := '111101101N';
  home := home || 'Calendar/';
  DB.DBA.DAV_MAKE_DIR (home, account_id, null, read_perm);

  home := home || CAL.WA.domain_gems_name(domain_id) || '/';
  DB.DBA.DAV_MAKE_DIR (home, account_id, null, read_perm);

  -- RSS 2.0
  path := home || 'Calendar.rss';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);

  content := CAL.WA.export_rss_sqlx (domain_id, account_id);
  DB.DBA.DAV_RES_UPLOAD_STRSES_INT (path, content, 'text/xml', exec_perm, http_dav_uid (), http_dav_uid () + 1, null, null, 0);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-template', 'execute', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-encoding', 'utf-8', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-description', 'RSS based XML document generated by OpenLink Calendar', 'dav', null, 0, 0, 1);

  -- ATOM
  path := home || 'Calendar.atom';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);

  content := CAL.WA.export_atom_sqlx (domain_id, account_id);
  DB.DBA.DAV_RES_UPLOAD_STRSES_INT (path, content, 'text/xml', exec_perm, http_dav_uid (), http_dav_uid () + 1, null, null, 0);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-template', 'execute', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-encoding', 'utf-8', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-description', 'ATOM based XML document generated by OpenLink Calendar', 'dav', null, 0, 0, 1);

  -- RDF
  path := home || 'Calendar.rdf';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);

  content := CAL.WA.export_rdf_sqlx (domain_id, account_id);
  DB.DBA.DAV_RES_UPLOAD_STRSES_INT (path, content, 'text/xml', exec_perm, http_dav_uid (), http_dav_uid () + 1, null, null, 0);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-template', 'execute', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-encoding', 'utf-8', 'dav', null, 0, 0, 1);
  DB.DBA.DAV_PROP_SET_INT (path, 'xml-sql-description', 'RDF based XML document generated by OpenLink Calendar', 'dav', null, 0, 0, 1);

  return;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_gems_delete (
  in domain_id integer,
  in account_id integer,
  in appName varchar := 'Calendar',
  in appGems varchar := null)
{
  declare tmp, home, path varchar;

  home := CAL.WA.dav_home (account_id);
  if (isnull (home))
    return;

  if (isnull (appGems))
    appGems := CAL.WA.domain_gems_name (domain_id);
  home := home || appName || '/' || appGems || '/';

  path := home || appName || '.rss';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);
  path := home || appName || '.rdf';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);
  path := home || appName || '.atom';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);
  path := home || appName || '.ocs';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);
  path := home || appName || '.opml';
  DB.DBA.DAV_DELETE_INT (path, 1, null, null, 0);

  declare auth_uid, auth_pwd varchar;

  auth_uid := coalesce((SELECT U_NAME FROM WS.WS.SYS_DAV_USER WHERE U_ID = account_id), '');
  auth_pwd := coalesce((SELECT U_PWD FROM WS.WS.SYS_DAV_USER WHERE U_ID = account_id), '');
  if (auth_pwd[0] = 0)
    auth_pwd := pwd_magic_calc (auth_uid, auth_pwd, 1);

  tmp := DB.DBA.DAV_DIR_LIST (home, 0, auth_uid, auth_pwd);
  if (not isinteger(tmp) and not length (tmp))
    DB.DBA.DAV_DELETE_INT (home, 1, null, null, 0);

  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_update (
  inout domain_id integer,
  inout account_id integer)
{
  CAL.WA.domain_gems_delete (domain_id, account_id, 'Calendar');
  CAL.WA.domain_gems_create (domain_id, account_id);

  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_owner_id (
  inout domain_id integer)
{
  return (select A.WAM_USER from WA_MEMBER A, WA_INSTANCE B where A.WAM_MEMBER_TYPE = 1 and A.WAM_INST = B.WAI_NAME and B.WAI_ID = domain_id);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_owner_name (
  inout domain_id integer)
{
  return (select C.U_NAME from WA_MEMBER A, WA_INSTANCE B, SYS_USERS C where A.WAM_MEMBER_TYPE = 1 and A.WAM_INST = B.WAI_NAME and B.WAI_ID = domain_id and C.U_ID = A.WAM_USER);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_delete (
  in domain_id integer)
{
  VHOST_REMOVE(lpath => concat('/calendar/', cast (domain_id as varchar)));
  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_id (
  in domain_name varchar)
{
  return (select WAI_ID from DB.DBA.WA_INSTANCE where WAI_NAME = domain_name);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_name (
  in domain_id integer)
{
  return coalesce((select WAI_NAME from DB.DBA.WA_INSTANCE where WAI_ID = domain_id), 'Calendar Instance');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_gems_name (
  in domain_id integer)
{
  return concat(CAL.WA.domain_name(domain_id), '_Gems');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_description (
  in domain_id integer)
{
  return coalesce((select coalesce(WAI_DESCRIPTION, WAI_NAME) from DB.DBA.WA_INSTANCE where WAI_ID = domain_id), 'Calendar Instance');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_is_public (
  in domain_id integer)
{
  return coalesce((select WAI_IS_PUBLIC from DB.DBA.WA_INSTANCE where WAI_ID = domain_id), 0);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.domain_ping (
  in domain_id integer)
{
  for (select WAI_NAME, WAI_DESCRIPTION from DB.DBA.WA_INSTANCE where WAI_ID = domain_id and WAI_IS_PUBLIC = 1) do {
    ODS..APP_PING (WAI_NAME, coalesce (WAI_DESCRIPTION, WAI_NAME), CAL.WA.sioc_url (domain_id));
  }
}
;

-------------------------------------------------------------------------------
--
-- Account Functions
--
-------------------------------------------------------------------------------
create procedure CAL.WA.account()
{
  declare vspx_user varchar;

  vspx_user := connection_get('owner_user');
  if (isnull (vspx_user))
    vspx_user := connection_get('vspx_user');
  return vspx_user;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.account_access (
  out auth_uid varchar,
  out auth_pwd varchar)
{
  auth_uid := CAL.WA.account();
  auth_pwd := coalesce((SELECT U_PWD FROM WS.WS.SYS_DAV_USER WHERE U_NAME = auth_uid), '');
  if (auth_pwd[0] = 0)
    auth_pwd := pwd_magic_calc(auth_uid, auth_pwd, 1);
  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.account_delete(
  in domain_id integer,
  in account_id integer)
{
  declare iCount any;

  select count(WAM_USER) into iCount
    from WA_MEMBER,
         WA_INSTANCE
   where WAI_NAME = WAM_INST
     and WAI_TYPE_NAME = 'Calendar'
     and WAM_USER = account_id;

  if (iCount = 0) {
    delete from CAL.WA.SETTINGS where S_ACCOUNT_ID = account_id;
  }
  CAL.WA.domain_gems_delete (domain_id, account_id);

  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.user_name(
  in u_name any,
  in u_full_name any) returns varchar
{
  if (not is_empty_or_null(trim(u_full_name)))
    return u_full_name;
  return u_name;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.tag_prepare(
  inout tag varchar)
{
  if (not is_empty_or_null(tag)) {
    tag := trim(tag);
    tag := replace (tag, '  ', ' ');
  }
  return tag;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.tag_delete(
  inout tags varchar,
  inout T integer)
{
  declare N integer;
  declare tags2 any;

  tags2 := CAL.WA.tags2vector(tags);
  tags := '';
  for (N := 0; N < length (tags2); N := N + 1)
    if (N <> T)
      tags := concat(tags, ',', tags2[N]);
  return trim(tags, ',');
}
;

---------------------------------------------------------------------------------
--
create procedure CAL.WA.tags_join(
  inout tags varchar,
  inout tags2 varchar)
{
  declare resultTags any;

  if (is_empty_or_null(tags))
    tags := '';
  if (is_empty_or_null(tags2))
    tags2 := '';

  resultTags := concat(tags, ',', tags2);
  resultTags := CAL.WA.tags2vector(resultTags);
  resultTags := CAL.WA.tags2unique(resultTags);
  resultTags := CAL.WA.vector2tags(resultTags);
  return resultTags;
}
;

---------------------------------------------------------------------------------
--
create procedure CAL.WA.tags2vector(
  inout tags varchar)
{
  return split_and_decode(trim(tags, ','), 0, '\0\0,');
}
;

---------------------------------------------------------------------------------
--
create procedure CAL.WA.tags2search(
  in tags varchar)
{
  declare S varchar;
  declare V any;

  S := '';
  V := CAL.WA.tags2vector(tags);
  foreach (any tag in V) do
    S := concat(S, ' ^T', replace (replace (trim(lcase(tag)), ' ', '_'), '+', '_'));
  return FTI_MAKE_SEARCH_STRING(trim(S, ','));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector2tags(
  inout aVector any)
{
  declare N integer;
  declare aResult any;

  aResult := '';
  for (N := 0; N < length (aVector); N := N + 1)
    if (N = 0) {
      aResult := trim(aVector[N]);
    } else {
      aResult := concat(aResult, ',', trim(aVector[N]));
    }
  return aResult;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.tags2unique(
  inout aVector any)
{
  declare aResult any;
  declare N, M integer;

  aResult := vector();
  for (N := 0; N < length (aVector); N := N + 1) {
    for (M := 0; M < length (aResult); M := M + 1)
      if (trim(lcase(aResult[M])) = trim(lcase(aVector[N])))
        goto _next;
    aResult := vector_concat(aResult, vector(trim(aVector[N])));
  _next:;
  }
  return aResult;
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dav_home(
  inout account_id integer) returns varchar
{
  declare name, home any;
  declare cid integer;

  name := coalesce((select U_NAME from DB.DBA.SYS_USERS where U_ID = account_id), -1);
  if (isinteger(name))
    return null;
  home := CAL.WA.dav_home_create(name);
  if (isinteger(home))
    return null;
  cid := DB.DBA.DAV_SEARCH_ID(home, 'C');
  if (isinteger(cid) and (cid > 0))
    return home;
  return null;
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dav_home_create(
  in user_name varchar) returns any
{
  declare user_id, cid integer;
  declare user_home varchar;

  whenever not found goto _error;

  if (is_empty_or_null(user_name))
    goto _error;
  user_home := DB.DBA.DAV_HOME_DIR(user_name);
  if (isstring (user_home))
    cid := DB.DBA.DAV_SEARCH_ID(user_home, 'C');
    if (isinteger(cid) and (cid > 0))
      return user_home;

  user_home := '/DAV/home/';
  DB.DBA.DAV_MAKE_DIR (user_home, http_dav_uid (), http_dav_uid () + 1, '110100100R');

  user_home := user_home || user_name || '/';
  user_id := (select U_ID from DB.DBA.SYS_USERS where U_NAME = user_name);
  DB.DBA.DAV_MAKE_DIR (user_home, user_id, null, '110100000R');
  USER_SET_OPTION(user_name, 'HOME', user_home);

  return user_home;

_error:
  return -18;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.host_url ()
{
  declare host varchar;

  declare exit handler for sqlstate '*' { goto _default; };

  if (is_http_ctx ()) {
    host := http_request_header (http_request_header ( ) , 'Host' , null , sys_connected_server_address ());
    if (isstring (host) and strchr (host , ':') is null) {
      declare hp varchar;
      declare hpa any;

      hp := sys_connected_server_address ();
      hpa := split_and_decode ( hp , 0 , '\0\0:');
      host := host || ':' || hpa [1];
    }
    goto _exit;
  }

_default:;
  host := cfg_item_value (virtuoso_ini_path (), 'URIQA', 'DefaultHost');
  if (host is not null)
    return host;
  host := sys_stat ('st_host_name');
  if (server_http_port () <> '80')
    host := host || ':' || server_http_port ();

_exit:;
  return 'http://' || host ;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.calendar_url (
  in domain_id integer)
{
  return concat(CAL.WA.host_url(), '/calendar/', cast (domain_id as varchar), '/');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.sioc_url (
  in domain_id integer)
{
  return sprintf ('http://%s/dataspace/%U/calendar/%U/sioc.rdf', DB.DBA.wa_cname (), CAL.WA.domain_owner_name (domain_id), replace (CAL.WA.domain_name (domain_id), '+', '%2B'));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.foaf_url (
  in domain_id integer)
{
  return sprintf('http://%s/dataspace/%s/about.rdf', DB.DBA.wa_cname (), CAL.WA.domain_owner_name (domain_id));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.event_url (
  in domain_id integer,
  in event_id integer)
{
  return concat(CAL.WA.calendar_url (domain_id), 'home.vspx?id=', cast (event_id as varchar));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.dav_url (
  in domain_id integer)
{
  declare home varchar;

  home := CAL.WA.dav_home (CAL.WA.domain_owner_id (domain_id));
  if (isnull (home))
    return '';
  return concat('http://', DB.DBA.wa_cname (), home, 'Calendar/', CAL.WA.domain_gems_name (domain_id), '/');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.dav_url2 (
  in domain_id integer,
  in account_id integer)
{
  declare home varchar;

  home := CAL.WA.dav_home(account_id);
  if (isnull (home))
    return '';
  return replace (concat(home, 'Calendar/', CAL.WA.domain_gems_name(domain_id), '/'), ' ', '%20');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.geo_url (
  in domain_id integer,
  in account_id integer)
{
  for (select WAUI_LAT, WAUI_LNG from WA_USER_INFO where WAUI_U_ID = account_id) do
    if ((not isnull (WAUI_LNG)) and (not isnull (WAUI_LAT)))
      return sprintf ('\n    <meta name="ICBM" content="%.2f, %.2f"><meta name="DC.title" content="%s">', WAUI_LNG, WAUI_LAT, CAL.WA.domain_name (domain_id));
  return '';
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.dav_content (
  inout uri varchar)
{
  declare cont varchar;
  declare hp any;

  declare exit handler for sqlstate '*' { return null;};

  declare N integer;
  declare oldUri, newUri, reqHdr, resHdr varchar;
  declare auth_uid, auth_pwd varchar;

  newUri := uri;
  reqHdr := null;
  CAL.WA.account_access (auth_uid, auth_pwd);
  reqHdr := sprintf ('Authorization: Basic %s', encode_base64(auth_uid || ':' || auth_pwd));

_again:
  N := N + 1;
  oldUri := newUri;
  commit work;
  cont := http_get (newUri, resHdr, 'GET', reqHdr);
  if (resHdr[0] like 'HTTP/1._ 30_ %') {
    newUri := http_request_header (resHdr, 'Location');
    newUri := WS.WS.EXPAND_URL (oldUri, newUri);
    if (N > 15)
      return null;
    if (newUri <> oldUri)
      goto _again;
  }
  if (resHdr[0] like 'HTTP/1._ 4__ %' or resHdr[0] like 'HTTP/1._ 5__ %')
    return null;

  return (cont);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.xslt_root()
{
  declare sHost varchar;

  sHost := cast (registry_get('calendar_path') as varchar);
  if (sHost = '0')
    return 'file://apps/calendar/xslt/';
  if (isnull (strstr(sHost, '/DAV/VAD')))
    return sprintf ('file://%sxslt/', sHost);
  return sprintf ('virt://WS.WS.SYS_DAV_RES.RES_FULL_PATH.RES_CONTENT:%sxslt/', sHost);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.xslt_full(
  in xslt_file varchar)
{
  return concat(CAL.WA.xslt_root(), xslt_file);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.xml_set(
  in id varchar,
  inout pXml varchar,
  in value varchar)
{
  declare aEntity any;

  {
    declare exit handler for SQLSTATE '*' {
      pXml := xtree_doc('<?xml version="1.0" encoding="UTF-8"?><settings />');
      goto _skip;
    };
    if (not isentity(pXml))
      pXml := xtree_doc(pXml);
  }
_skip:
  aEntity := xpath_eval(sprintf ('/settings/entry[@ID = "%s"]', id), pXml);
  if (not isnull (aEntity))
    pXml := XMLUpdate(pXml, sprintf ('/settings/entry[@ID = "%s"]', id), null);

  if (not is_empty_or_null(value)) {
    aEntity := xpath_eval('/settings', pXml);
    XMLAppendChildren(aEntity, xtree_doc(sprintf ('<entry ID="%s">%s</entry>', id, CAL.WA.xml2string(value))));
  }
  return pXml;
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.xml_get(
  in id varchar,
  inout pXml varchar,
  in defaultValue any := '')
{
  declare value any;

  declare exit handler for SQLSTATE '*' {return defaultValue;};

  if (not isentity(pXml))
    pXml := xtree_doc(pXml);
  value := xpath_eval (sprintf ('string(/settings/entry[@ID = "%s"]/.)', id), pXml);
  if (is_empty_or_null(value))
    return defaultValue;

  return CAL.WA.wide2utf(value);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.string2xml (
  in content varchar,
  in mode integer := 0)
{
  if (mode = 0) {
    declare exit handler for sqlstate '*' { goto _html; };
    return xml_tree_doc (xml_tree (content, 0));
  }
_html:;
  return xml_tree_doc(xml_tree(content, 2, '', 'UTF-8'));
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.xml2string(
  in pXml any)
{
  declare sStream any;

  sStream := string_output();
  http_value(pXml, null, sStream);
  return string_output_string(sStream);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.normalize_space(
  in S varchar)
{
  return xpath_eval ('normalize-space (string(/a))', XMLELEMENT('a', S), 1);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.utfClear(
  inout S varchar)
{
  declare N integer;
  declare retValue varchar;

  retValue := '';
  for (N := 0; N < length (S); N := N + 1) {
    if (S[N] <= 31) {
      retValue := concat(retValue, '?');
    } else {
      retValue := concat(retValue, chr(S[N]));
    }
  }
  return retValue;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.utf2wide (
  inout S any)
{
  if (isstring (S))
    return charset_recode (S, 'UTF-8', '_WIDE_');
  return S;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.wide2utf (
  inout S any)
{
  if (iswidestring (S))
    return charset_recode (S, '_WIDE_', 'UTF-8' );
  return charset_recode (S, null, 'UTF-8' );
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.stringCut (
  in S varchar,
  in L integer := 60)
{
  declare tmp any;

  if (not L)
    return S;
  tmp := CAL.WA.utf2wide(S);
  if (not iswidestring(tmp))
    return S;
  if (length (tmp) > L)
    return CAL.WA.wide2utf(concat(subseq(tmp, 0, L-3), '...'));
  return CAL.WA.wide2utf(tmp);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_unique(
  inout aVector any,
  in minLength integer := 0)
{
  declare aResult any;
  declare N, M integer;

  aResult := vector();
  for (N := 0; N < length (aVector); N := N + 1) {
    if ((minLength = 0) or (length (aVector[N]) >= minLength)) {
      for (M := 0; M < length (aResult); M := M + 1)
        if (trim(aResult[M]) = trim(aVector[N]))
          goto _next;
      aResult := vector_concat(aResult, vector(aVector[N]));
    }
  _next:;
  }
  return aResult;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_except(
  inout aVector any,
  inout aExcept any)
{
  declare aResult any;
  declare N, M integer;

  aResult := vector();
  for (N := 0; N < length (aVector); N := N + 1) {
    for (M := 0; M < length (aExcept); M := M + 1)
      if (aExcept[M] = aVector[N])
        goto _next;
    aResult := vector_concat(aResult, vector(trim(aVector[N])));
  _next:;
  }
  return aResult;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_contains(
  inout aVector any,
  in value varchar)
{
  declare N integer;

  for (N := 0; N < length (aVector); N := N + 1)
    if (value = aVector[N])
      return 1;
  return 0;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_cut(
  inout aVector any,
  in value varchar)
{
  declare N integer;
  declare retValue any;

  retValue := vector ();
  for (N := 0; N < length (aVector); N := N + 1)
    if (value <> aVector[N])
      retValue := vector_concat (retValue, vector(aVector[N]));
  return retValue;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_set (
  inout aVector any,
  in aIndex any,
  in aValue varchar)
{
  declare N integer;
  declare retValue any;

  retValue := vector();
  for (N := 0; N < length (aVector); N := N + 1)
    if (aIndex = N) {
      retValue := vector_concat (retValue, vector(aValue));
    } else {
      retValue := vector_concat (retValue, vector(aVector[N]));
    }
  return retValue;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector_search(
  in aVector any,
  in value varchar,
  in condition vrchar := 'AND')
{
  declare N integer;

  for (N := 0; N < length (aVector); N := N + 1)
    if (value like concat('%', aVector[N], '%')) {
      if (condition = 'OR')
        return 1;
    } else {
      if (condition = 'AND')
        return 0;
    }
  return 0;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector2str(
  inout aVector any,
  in delimiter varchar := ' ')
{
  declare tmp, aResult any;
  declare N integer;

  aResult := '';
  for (N := 0; N < length (aVector); N := N + 1) {
    tmp := trim(aVector[N]);
    if (strchr (tmp, ' ') is not null)
      tmp := concat('''', tmp, '''');
    if (N = 0) {
      aResult := tmp;
    } else {
      aResult := concat(aResult, delimiter, tmp);
    }
  }
  return aResult;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector2rs(
  inout aVector any)
{
  declare N integer;
  declare c0 varchar;

  result_names(c0);
  for (N := 0; N < length (aVector); N := N + 1)
    result(aVector[N]);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.tagsDictionary2rs(
  inout aDictionary any)
{
  declare N integer;
  declare c0 varchar;
  declare c1 integer;
  declare V any;

  V := dict_to_vector(aDictionary, 1);
  result_names(c0, c1);
  for (N := 1; N < length (V); N := N + 2)
    result(V[N][0], V[N][1]);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.vector2src(
  inout aVector any)
{
  declare N integer;
  declare aResult any;

  aResult := 'vector(';
  for (N := 0; N < length (aVector); N := N + 1) {
    if (N = 0)
      aResult := concat(aResult, '''', trim(aVector[N]), '''');
    if (N <> 0)
      aResult := concat(aResult, ', ''', trim(aVector[N]), '''');
  }
  return concat(aResult, ')');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.ft2vector(
  in S any)
{
  declare w varchar;
  declare aResult any;

  aResult := vector();
  w := regexp_match ('["][^"]+["]|[''][^'']+['']|[^"'' ]+', S, 1);
  while (w is not null) {
    w := trim (w, '"'' ');
    if (upper(w) not in ('AND', 'NOT', 'NEAR', 'OR') and length (w) > 1 and not vt_is_noise (CAL.WA.wide2utf(w), 'utf-8', 'x-ViDoc'))
      aResult := vector_concat(aResult, vector(w));
    w := regexp_match ('["][^"]+["]|[''][^'']+['']|[^"'' ]+', S, 1);
  }
  return aResult;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.set_keyword (
  in    name   varchar,
  inout params any,
  in    value  any)
{
  declare N integer;

  for (N := 0; N < length (params); N := N + 2)
    if (params[N] = name) {
      aset(params, N + 1, value);
      goto _end;
    }

  params := vector_concat(params, vector(name, value));

_end:
  return params;
}
;

-------------------------------------------------------------------------------
--
-- Show functions
--
-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_text (
  in S any,
  in S2 any)
{
  if (isstring (S))
    S := trim(S);
  if (is_empty_or_null(S))
    return sprintf ('No %s', S2);
  return S;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_title(
  in S any)
{
  return CAL.WA.show_text(S, 'title');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_subject (
  in S any)
{
  return CAL.WA.show_text(S, 'subject');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_author(
  in S any)
{
  return CAL.WA.show_text(S, 'author');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_description(
  in S any)
{
  return CAL.WA.show_text(S, 'description');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.show_excerpt(
  in S varchar,
  in words varchar)
{
  return coalesce (search_excerpt (words, cast (S as varchar)), '');
}
;

-------------------------------------------------------------------------------
--
-- Date / Time functions
--
-------------------------------------------------------------------------------
--
-- returns user's now (based on timezone)
--
--------------------------------------------------------------------------------
create procedure CAL.WA.dt_now (
  in tz integer := null)
{
  if (isnull (tz))
    tz := timezone (now());
  return dateadd ('minute', tz - timezone (now()), now());
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_decode (
  inout pDateTime datetime,
  inout pYear integer,
  inout pMonth integer,
  inout pDay integer,
  inout pHour integer,
  inout pMinute integer)
{
  pYear := year (pDateTime);
  pMonth := month (pDateTime);
  pDay := dayofmonth (pDateTime);
  pHour := hour (pDateTime);
  pMinute := minute (pDateTime);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_encode (
  in pYear integer,
  in pMonth integer,
  in pDay integer,
  in pHour integer,
  in pMinute integer)
{
  return stringdate (sprintf ('%d.%d.%d %d:%d', pYear, pMonth, pDay, pHour, pMinute));
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_join (
  in pDate date,
  in pTime time)
{
  declare pYear, pMonth, pDay, pHour, pMinute integer;

  CAL.WA.dt_dateDecode (pDate, pYear, pMonth, pDay);
  CAL.WA.dt_timeDecode (pTime, pHour, pMinute);
  return CAL.WA.dt_encode (pYear, pMonth, pDay, pHour, pMinute);
}
;

--------------------------------------------------------------------------------
--
-- compare two dates by yyyy.mm.dd components
--
--------------------------------------------------------------------------------
create procedure CAL.WA.dt_compare (
  in pDate1 datetime,
  in pDate2 datetime)
{
  if ((year (pDate1) = year (pDate2)) and (month (pDate1) = month (pDate2)) and (dayofmonth (pDate1) = dayofmonth (pDate2)))
    return 1;
  return 0;
}
;

--------------------------------------------------------------------------------
--
-- returns user's date (based on timezone)
--
--------------------------------------------------------------------------------
create procedure CAL.WA.dt_curdate (
  in tz integer := null)
{
  declare pYear, pMonth, pDay integer;
  declare dt date;

  if (isnull (tz))
    tz := timezone (now());
  return CAL.WA.dt_dateClear (dateadd ('minute', tz - timezone (now()), now()));
}
;

--------------------------------------------------------------------------------
--
-- returns date without time
--
--------------------------------------------------------------------------------
create procedure CAL.WA.dt_dateClear (
  in pDate date)
{
  declare pYear, pMonth, pDay integer;

  if (isnull (pDate))
    return pDate;
  CAL.WA.dt_dateDecode (pDate, pYear, pMonth, pDay);
  return CAL.WA.dt_dateEncode (pYear, pMonth, pDay);
}
;

--------------------------------------------------------------------------------
--
-- returns user's date (based on timezone)
--
--------------------------------------------------------------------------------
create procedure CAL.WA.dt_curtime (
  in tz integer := null)
{
  if (isnull (tz))
    tz := timezone (now());
  return cast (dateadd ('minute', tz - timezone (now()), now()) as time);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_datestring (
  in dt datetime,
  in pFormat varchar := 'd.m.Y')
{
  return CAL.WA.dt_format (dt, pFormat);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_stringdate (
  in pString varchar,
  in pFormat varchar := 'd.m.Y')
{
  return CAL.WA.dt_deformat (pString, pFormat);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_dateDecode(
  inout pDate date,
  inout pYear integer,
  inout pMonth integer,
  inout pDay integer)
{
  pYear := year (pDate);
  pMonth := month (pDate);
  pDay := dayofmonth (pDate);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_dateEncode(
  in pYear integer,
  in pMonth integer,
  in pDay integer)
{
  return cast (stringdate (sprintf ('%d.%d.%d', pYear, pMonth, pDay)) as date);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_format (
  in dt datetime,
  in pFormat varchar := 'd.m.Y')
{
  declare
    N integer;
  declare
    ch,
    S varchar;

  declare exit handler for sqlstate '*' {
    return '';
  };

  pFormat := CAL.WA.dt_formatTemplate (pFormat);
  S := '';
  N := 1;
  while (N <= length (pFormat))
  {
    ch := substring (pFormat, N, 1);
    if (ch = 'M')
    {
      S := concat(S, xslt_format_number(month(dt), '00'));
    } else {
      if (ch = 'm')
      {
        S := concat(S, xslt_format_number(month(dt), '##'));
      } else
      {
        if (ch = 'Y')
        {
          S := concat(S, xslt_format_number(year(dt), '0000'));
        } else
        {
          if (ch = 'y')
          {
            S := concat(S, substring (xslt_format_number(year(dt), '0000'),3,2));
          } else {
            if (ch = 'd')
            {
              S := concat(S, xslt_format_number(dayofmonth(dt), '##'));
            } else
            {
              if (ch = 'D')
              {
                S := concat(S, xslt_format_number(dayofmonth(dt), '00'));
              } else
              {
                if (ch = 'H')
                {
                  S := concat(S, xslt_format_number(hour(dt), '00'));
                } else
                {
                  if (ch = 'h')
                  {
                    S := concat(S, xslt_format_number(hour(dt), '##'));
                  } else
                  {
                    if (ch = 'N')
                    {
                      S := concat(S, xslt_format_number(minute(dt), '00'));
                    } else
                    {
                      if (ch = 'n')
                      {
                        S := concat(S, xslt_format_number(minute(dt), '##'));
                      } else
                      {
                        if (ch = 'S')
                        {
                          S := concat(S, xslt_format_number(second(dt), '00'));
                        } else
                        {
                          if (ch = 's')
                          {
                            S := concat(S, xslt_format_number(second(dt), '##'));
                          } else
                          {
                            S := concat(S, ch);
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    N := N + 1;
  };
  return S;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_deformat (
  in pString varchar,
  in pFormat varchar := 'd.m.Y')
{
  declare
    y,
    m,
    d integer;
  declare
    N,
    I integer;
  declare
    ch varchar;

  pFormat := CAL.WA.dt_formatTemplate (pFormat);
  N := 1;
  I := 0;
  d := 0;
  m := 0;
  y := 0;
  while (N <= length (pFormat)) {
    ch := upper (substring (pFormat, N, 1));
    if (ch = 'M')
      m := CAL.WA.dt_deformat_tmp (pString, I);
    if (ch = 'D')
      d := CAL.WA.dt_deformat_tmp (pString, I);
    if (ch = 'Y') {
      y := CAL.WA.dt_deformat_tmp (pString, I);
      if (y < 50)
        y := 2000 + y;
      if (y < 100)
        y := 1900 + y;
    };
    N := N + 1;
  };
  return stringdate(concat(cast (m as varchar), '.', cast (d as varchar), '.', cast (y as varchar)));
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_deformat_tmp (
  in S varchar,
  inout N varchar)
{
  declare
    V any;

  V := regexp_parse('[0-9]+', S, N);
  if (length (V) > 1) {
    N := V[1];
    return atoi (subseq (S, V[0], V[1]));
  }
  N := N + 1;
  return 0;
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_reformat(
  in pString varchar,
  in pInFormat varchar := 'd.m.Y',
  in pOutFormat varchar := 'm.d.Y')
{
  pInFormat := CAL.WA.dt_formatTemplate (pInFormat);
  pOutFormat := CAL.WA.dt_formatTemplate (pOutFormat);
  return CAL.WA.dt_format(CAL.WA.dt_deformat(pString, pInFormat), pOutFormat);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_formatTemplate (
  in pFormat varchar := 'dd.MM.yyyy')
{
  if (pFormat = 'dd.MM.yyyy')
    return 'D.M.Y';
  if (pFormat = 'MM/dd/yyyy')
    return 'M/d/Y';
  if (pFormat = 'yyyy/MM/dd')
    return 'Y/M/d';
  return pFormat;
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_timeDecode(
  inout pTime time,
  inout pHour integer,
  inout pMinute integer)
{
  pHour := hour (pTime);
  pMinute := minute (pTime);
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_timeEncode(
  in pHour integer,
  in pMinute integer)
{
  return stringtime (sprintf ('%d:%d', pHour, pMinute));
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_timestring (
  in pTime integer,
  in pFormat varchar := 'e')
{
  declare h, m integer;

  CAL.WA.dt_timeDecode (pTime, h, m);
  if (pFormat = 'e')
    return sprintf ('%s:%s', xslt_format_number (h, '00'), xslt_format_number (m, '00'));
  if (h = 0)
    return '12:00 am';
  if (h < 12)
    return sprintf ('%s:%s am', xslt_format_number (h, '00'), xslt_format_number (m, '00'));
  if (h = 12)
    return '12:00 pm';
  if (h < 24)
    return sprintf ('%s:%s pm', xslt_format_number (h-12, '00'), xslt_format_number (m, '00'));
  return '';
}
;

-----------------------------------------------------------------------------
--
create procedure CAL.WA.dt_stringtime (
  in pString varchar)
{
  declare am, pm integer;
  declare pTime time;

  am := 0;
  pm := 0;
  pString := lcase (pString);
  if (not isnull (strstr (pString, 'am'))) {
    am := 1;
    pString := replace (pString, 'am', '');
  }
  if (not isnull (strstr (pString, 'pm'))) {
    pm := 1;
    pString := replace (pString, 'pm', '');
  }
  pTime := stringtime (trim (pString));
  if (am = 1) {
    if (hour (pTime) = 12)
      pTime := dateadd ('hour', 12, pTime);
  }
  if (pm = 1) {
    if (hour (pTime) = 12) {
      pTime := dateadd ('hour', -12, pTime);
    } else {
      pTime := dateadd ('hour', 12, pTime);
    }
  }
  return cast (pTime as time);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_timeFloor (
  in pTime integer,
  in pRound integer := 0)
{
  declare h, m integer;

  if (pRound = 0)
    return pTime;
  CAL.WA.dt_timeDecode (pTime, h, m);
  return CAL.WA.dt_timeEncode (h, floor (cast (m as float) / pRound) * pRound);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_timeCeiling (
  in pTime integer,
  in pRound integer := 0)
{
  declare h, m integer;

  if (pRound = 0)
    return pTime;
  CAL.WA.dt_timeDecode (pTime, h, m);
  return CAL.WA.dt_timeEncode (h, ceiling (cast (m as float) / pRound) * pRound);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_rfc1123 (
  in dt datetime)
{
  return soap_print_box (dt, '', 1);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_iso8601 (
  in dt datetime)
{
  return soap_print_box (dt, '', 0);
}
;

-----------------------------------------------------------------------------------------
--
-- the week kind: s - Sunday;
--                m - Monday
--
create procedure CAL.WA.dt_WeekDay (
  in dt datetime,
  in weekStarts varchar := 'm')
{
  declare dw integer;

  dw := dayofweek (dt);
  if (weekStarts = 'm') {
    if (dw = 1)
      return 7;
    return dw - 1;
  }
  return dw;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_WeekName (
  in dt datetime,
  in weekStarts varchar := 'm',
  in nameLenght integer := 0)
{
  declare N integer;
  declare names any;

  N := CAL.WA.dt_WeekDay (dt, weekStarts);
  names := CAL.WA.dt_WeekNames (weekStarts, nameLenght);
  return names [N-1];
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_WeekNames (
  in weekStarts varchar := 'm',
  in nameLenght integer := 0)
{
  declare N integer;
  declare names any;

  if (weekStarts = 'm') {
    names := vector ('Monday', 'Tuesday', 'Wednesday', 'Thursday ', 'Friday', 'Saturday', 'Sunday');
  } else {
    names := vector ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday ', 'Friday', 'Saturday');
  }
  if (nameLenght <> 0)
    for (N := 0; N < length (names); N := N + 1)
      aset (names, N, subseq (names[N], 0, nameLenght));
  return names;

}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_BeginOfWeek (
  in dt date,
  in weekStarts varchar := 'm')
{
  return CAL.WA.dt_dateClear (dateadd ('day', 1-CAL.WA.dt_WeekDay (dt, weekStarts), dt));
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_EndOfWeek (
  in dt date,
  in weekStarts varchar := 'm')
{
  return CAL.WA.dt_dateClear (dateadd ('day', -1, dateadd ('day', 7, CAL.WA.dt_BeginOfWeek (dt, weekStarts))));
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_BeginOfMonth (
  in dt datetime)
{
  return dateadd ('day', -(dayofmonth (dt)-1), dt);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_EndOfMonth (
  in dt datetime)
{
  return dateadd ('day', -1, dateadd ('month', 1, CAL.WA.dt_BeginOfMonth (dt)));
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.dt_LastDayOfMonth (
  in dt datetime)
{
  return dayofmonth (CAL.WA.dt_EndOfMonth (dt));
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.test_clear (
  in S any)
{
  declare N integer;

  return substring (S, 1, coalesce(strstr(S, '<>'), length (S)));
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.test (
  in value any,
  in params any := null)
{
  declare valueType, valueClass, valueName, valueMessage, tmp any;

  declare exit handler for SQLSTATE '*' {
    if (not is_empty_or_null(valueMessage))
      signal ('TEST', valueMessage);
    if (__SQL_STATE = 'EMPTY')
      signal ('TEST', sprintf ('Field ''%s'' cannot be empty!<>', valueName));
    if (__SQL_STATE = 'CLASS') {
      if (valueType in ('free-text', 'tags')) {
        signal ('TEST', sprintf ('Field ''%s'' contains invalid characters or noise words!<>', valueName));
      } else {
        signal ('TEST', sprintf ('Field ''%s'' contains invalid characters!<>', valueName));
      }
    }
    if (__SQL_STATE = 'TYPE')
      signal ('TEST', sprintf ('Field ''%s'' contains invalid characters for \'%s\'!<>', valueName, valueType));
    if (__SQL_STATE = 'MIN')
      signal ('TEST', sprintf ('''%s'' value should be greater then %s!<>', valueName, cast (tmp as varchar)));
    if (__SQL_STATE = 'MAX')
      signal ('TEST', sprintf ('''%s'' value should be less then %s!<>', valueName, cast (tmp as varchar)));
    if (__SQL_STATE = 'MINLENGTH')
      signal ('TEST', sprintf ('The length of field ''%s'' should be greater then %s characters!<>', valueName, cast (tmp as varchar)));
    if (__SQL_STATE = 'MAXLENGTH')
      signal ('TEST', sprintf ('The length of field ''%s'' should be less then %s characters!<>', valueName, cast (tmp as varchar)));
    signal ('TEST', 'Unknown validation error!<>');
    --resignal;
  };

  value := trim(value);
  if (is_empty_or_null(params))
    return value;

  valueClass := coalesce (get_keyword ('class', params), get_keyword ('type', params));
  valueType := coalesce (get_keyword ('type', params), get_keyword ('class', params));
  valueName := get_keyword ('name', params, 'Field');
  valueMessage := get_keyword ('message', params, '');
  tmp := get_keyword ('canEmpty', params);
  if (isnull (tmp)) {
    if (not isnull (get_keyword ('minValue', params))) {
      tmp := 0;
    } else if (get_keyword ('minLength', params, 0) <> 0) {
      tmp := 0;
    }
  }
  if (not isnull (tmp) and (tmp = 0) and is_empty_or_null(value)) {
    signal('EMPTY', '');
  } else if (is_empty_or_null(value)) {
    return value;
  }

  value := CAL.WA.validate2 (valueClass, value);

  if (valueType = 'integer') {
    tmp := get_keyword ('minValue', params);
    if ((not isnull (tmp)) and (value < tmp))
      signal('MIN', cast (tmp as varchar));

    tmp := get_keyword ('maxValue', params);
    if (not isnull (tmp) and (value > tmp))
      signal('MAX', cast (tmp as varchar));

  } else if (valueType = 'float') {
    tmp := get_keyword ('minValue', params);
    if (not isnull (tmp) and (value < tmp))
      signal('MIN', cast (tmp as varchar));

    tmp := get_keyword ('maxValue', params);
    if (not isnull (tmp) and (value > tmp))
      signal('MAX', cast (tmp as varchar));

  } else if (valueType = 'varchar') {
    tmp := get_keyword ('minLength', params);
    if (not isnull (tmp) and (length (CAL.WA.utf2wide(value)) < tmp))
      signal('MINLENGTH', cast (tmp as varchar));

    tmp := get_keyword ('maxLength', params);
    if (not isnull (tmp) and (length (CAL.WA.utf2wide(value)) > tmp))
      signal('MAXLENGTH', cast (tmp as varchar));
  }
  return value;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate2 (
  in propertyType varchar,
  in propertyValue varchar)
{
  declare exit handler for SQLSTATE '*' {
    if (__SQL_STATE = 'CLASS')
      resignal;
    signal('TYPE', propertyType);
    return;
  };

  if (propertyType = 'boolean') {
    if (propertyValue not in ('Yes', 'No'))
      goto _error;
  } else if (propertyType = 'integer') {
    if (isnull (regexp_match('^[0-9]+\$', propertyValue)))
      goto _error;
    return cast (propertyValue as integer);
  } else if (propertyType = 'float') {
    if (isnull (regexp_match('^[-+]?([0-9]*\.)?[0-9]+([eE][-+]?[0-9]+)?\$', propertyValue)))
      goto _error;
    return cast (propertyValue as float);
  } else if (propertyType = 'dateTime') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01]) ([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      goto _error;
    return cast (propertyValue as datetime);
  } else if (propertyType = 'dateTime2') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01]) ([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      goto _error;
    return cast (propertyValue as datetime);
  } else if (propertyType = 'date') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\$', propertyValue)))
      goto _error;
    return cast (propertyValue as datetime);
  } else if (propertyType = 'date2') {
    if (isnull (regexp_match('^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]((?:19|20)[0-9][0-9])\$', propertyValue)))
      goto _error;
    return stringdate(CAL.WA.dt_reformat(propertyValue, 'd.m.Y', 'Y-M-D'));
  } else if (propertyType = 'date-dd.MM.yyyy') {
    if (isnull (regexp_match('^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]((?:19|20)[0-9][0-9])\$', propertyValue)))
      goto _error;
    return CAL.WA.dt_stringdate (propertyValue, 'dd.MM.yyyy');
  } else if (propertyType = 'date-MM/dd/yyyy') {
    if (isnull (regexp_match('^(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.]((?:19|20)[0-9][0-9])\$', propertyValue)))
      goto _error;
    return CAL.WA.dt_stringdate (propertyValue, 'MM/dd/yyyy');
  } else if (propertyType = 'date-yyyy/MM/dd') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\$', propertyValue)))
      goto _error;
    return CAL.WA.dt_stringdate (propertyValue, 'yyyy/MM/dd');
  } else if (propertyType = 'time') {
    if (isnull (regexp_match('^([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      goto _error;
    return cast (propertyValue as time);
  } else if (propertyType = 'folder') {
    if (isnull (regexp_match('^[^\\\/\?\*\"\'\>\<\:\|]*\$', propertyValue)))
      goto _error;
  } else if ((propertyType = 'uri') or (propertyType = 'anyuri')) {
    if (isnull (regexp_match('^(ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*(:(0-9)*)*(\/?)([a-zA-Z0-9\-\.\?\,\'\/\\\+&amp;%\$#_=:]*)?\$', propertyValue)))
      goto _error;
  } else if (propertyType = 'email') {
    if (isnull (regexp_match('^([a-zA-Z0-9_\-])+(\.([a-zA-Z0-9_\-])+)*@((\[(((([0-1])?([0-9])?[0-9])|(2[0-4][0-9])|(2[0-5][0-5])))\.(((([0-1])?([0-9])?[0-9])|(2[0-4][0-9])|(2[0-5][0-5])))\.(((([0-1])?([0-9])?[0-9])|(2[0-4][0-9])|(2[0-5][0-5])))\.(((([0-1])?([0-9])?[0-9])|(2[0-4][0-9])|(2[0-5][0-5]))\]))|((([a-zA-Z0-9])+(([\-])+([a-zA-Z0-9])+)*\.)+([a-zA-Z])+(([\-])+([a-zA-Z0-9])+)*))\$', propertyValue)))
      goto _error;
  } else if (propertyType = 'free-text') {
    if (length (propertyValue))
      if (not CAL.WA.validate_freeTexts(propertyValue))
        goto _error;
  } else if (propertyType = 'free-text-expression') {
    if (length (propertyValue))
      if (not CAL.WA.validate_freeText(propertyValue))
        goto _error;
  } else if (propertyType = 'tags') {
    if (not CAL.WA.validate_tags(propertyValue))
      goto _error;
  }
  return propertyValue;

_error:
  signal('CLASS', propertyType);
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate (
  in propertyType varchar,
  in propertyValue varchar,
  in propertyEmpty integer := 1)
{
  if (is_empty_or_null(propertyValue))
    return propertyEmpty;

  declare tmp any;
  declare exit handler for SQLSTATE '*' {return 0;};

  if (propertyType = 'boolean') {
    if (propertyValue not in ('Yes', 'No'))
      return 0;
  } else if (propertyType = 'integer') {
    if (isnull (regexp_match('^[0-9]+\$', propertyValue)))
      return 0;
    tmp := cast (propertyValue as integer);
  } else if (propertyType = 'float') {
    if (isnull (regexp_match('^[-+]?([0-9]*\.)?[0-9]+([eE][-+]?[0-9]+)?\$', propertyValue)))
      return 0;
    tmp := cast (propertyValue as float);
  } else if (propertyType = 'dateTime') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01]) ([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      return 0;
  } else if (propertyType = 'dateTime2') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01]) ([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      return 0;
  } else if (propertyType = 'date') {
    if (isnull (regexp_match('^((?:19|20)[0-9][0-9])[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\$', propertyValue)))
      return 0;
  } else if (propertyType = 'date2') {
    if (isnull (regexp_match('^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]((?:19|20)[0-9][0-9])\$', propertyValue)))
      return 0;
  } else if (propertyType = 'time') {
    if (isnull (regexp_match('^([01]?[0-9]|[2][0-3])(:[0-5][0-9])?\$', propertyValue)))
      return 0;
  } else if (propertyType = 'folder') {
    if (isnull (regexp_match('^[^\\\/\?\*\"\'\>\<\:\|]*\$', propertyValue)))
      return 0;
  } else if (propertyType = 'uri') {
    if (isnull (regexp_match('^(ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*(:(0-9)*)*(\/?)([a-zA-Z0-9\-\.\?\,\'\/\\\+&amp;%\$#_]*)?\$', propertyValue)))
      return 0;
  }
  return 1;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate_freeText (
  in S varchar)
{
  declare st, msg varchar;

  if (upper(S) in ('AND', 'NOT', 'NEAR', 'OR'))
    return 0;
  if (length (S) < 2)
    return 0;
  if (vt_is_noise (CAL.WA.wide2utf(S), 'utf-8', 'x-ViDoc'))
    return 0;
  st := '00000';
  exec (sprintf ('vt_parse (\'[__lang "x-ViDoc" __enc "utf-8"] %s\')', S), st, msg, vector ());
  if (st <> '00000')
    return 0;
  return 1;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate_freeTexts (
  in S any)
{
  declare w varchar;

  w := regexp_match ('["][^"]+["]|[''][^'']+['']|[^"'' ]+', S, 1);
  while (w is not null) {
    w := trim (w, '"'' ');
    if (not CAL.WA.validate_freeText(w))
      return 0;
    w := regexp_match ('["][^"]+["]|[''][^'']+['']|[^"'' ]+', S, 1);
  }
  return 1;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate_tag (
  in S varchar)
{
  S := replace (trim(S), '+', '_');
  S := replace (trim(S), ' ', '_');
  if (not CAL.WA.validate_freeText(S))
    return 0;
  if (not isnull (strstr(S, '"')))
    return 0;
  if (not isnull (strstr(S, '''')))
    return 0;
  if (length (S) < 2)
    return 0;
  if (length (S) > 50)
    return 0;
  return 1;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.validate_tags (
  in S varchar)
{
  declare N integer;
  declare V any;

  V := CAL.WA.tags2vector(S);
  if (is_empty_or_null(V))
    return 0;
  if (length (V) <> length (CAL.WA.tags2unique(V)))
    return 0;
  for (N := 0; N < length (V); N := N + 1)
    if (not CAL.WA.validate_tag(V[N]))
      return 0;
  return 1;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.dashboard_get(
  in domain_id integer,
  in user_id integer)
{
  declare ses any;

  ses := string_output ();
  http ('<calendar-db>', ses);
  http ('</calendar-db>', ses);
  return string_output_string (ses);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings (
  inout account_id integer)
{
  return coalesce((select deserialize(blob_to_string(S_DATA)) from CAL.WA.SETTINGS where S_ACCOUNT_ID = account_id), vector());
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_rows (
  in settings any)
{
  return cast (get_keyword ('rows', settings, '10') as integer);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_chars (
  in settings any)
{
  return cast (get_keyword ('chars', settings, '0') as integer);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_atomVersion (
  in settings any)
{
  return get_keyword ('atomVersion', settings, '1.0');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_defaultView (
  in settings any)
{
  return get_keyword ('defaultView', settings, 'week');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_weekStarts (
  in settings any)
{
  return get_keyword ('weekStarts', settings, 'm');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_timeZone (
  in settings any)
{
  return cast (get_keyword ('timeZone', settings, '0') as integer);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_dateFormat (
  in settings any)
{
  return get_keyword ('dateFormat', settings, 'dd.MM.yyyy');
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.settings_timeFormat (
  in settings any)
{
  return get_keyword ('timeFormat', settings, 'e');
}
;

-----------------------------------------------------------------------------------------
--
-- Events
--
-----------------------------------------------------------------------------------------
create procedure CAL.WA.event_kind (
  in id integer)
{
  declare tmp integer;

  tmp := (select E_KIND from CAL.WA.EVENTS where E_ID = id);
  if (tmp = 0)
    return 'event';
  if (tmp = 1)
    return 'task';
  if (tmp = 2)
    return 'note';
  return null;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.event_update (
  in id integer,
  in domain_id integer,
  in subject varchar,
  in description varchar,
  in location varchar,
  in tags varchar,
  in event integer,
  in eventStart datetime,
  in eventEnd datetime,
  in eventRepeat varchar,
  in eventRepeatParam1 integer,
  in eventRepeatParam2 integer,
  in eventRepeatParam3 integer,
  in eventRepeatUntil datetime,
  in eventReminder integer)
{
  if (id = -1) {
    id := sequence_next ('CAL.WA.event_id');
    insert into CAL.WA.EVENTS
      (
        E_ID,
        E_DOMAIN_ID,
        E_SUBJECT,
        E_DESCRIPTION,
        E_LOCATION,
        E_TAGS,
        E_EVENT,
        E_EVENT_START,
        E_EVENT_END,
        E_REPEAT,
        E_REPEAT_PARAM1,
        E_REPEAT_PARAM2,
        E_REPEAT_PARAM3,
        E_REPEAT_UNTIL,
        E_REMINDER,
        E_CREATED,
        E_UPDATED
      )
      values
      (
        id,
        domain_id,
        subject,
        description,
        location,
        tags,
        event,
        eventStart,
        eventEnd,
        eventRepeat,
        eventRepeatParam1,
        eventRepeatParam2,
        eventRepeatParam3,
        eventRepeatUntil,
        eventReminder,
        now (),
        now ()
      );
  } else {
    update CAL.WA.EVENTS
       set E_SUBJECT = subject,
           E_DESCRIPTION = description,
           E_LOCATION = location,
           E_TAGS = tags,
           E_EVENT = event,
           E_EVENT_START = eventStart,
           E_EVENT_END = eventEnd,
           E_REPEAT = eventRepeat,
           E_REPEAT_PARAM1 = eventRepeatParam1,
           E_REPEAT_PARAM2 = eventRepeatParam2,
           E_REPEAT_PARAM3 = eventRepeatParam3,
           E_REPEAT_UNTIL = eventRepeatUntil,
           E_REMINDER = eventReminder,
           E_UPDATED = now ()
     where E_ID = id and
           E_DOMAIN_ID = domain_id;
  }
  return id;
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.event_delete (
  in id integer,
  in domain_id integer,
  in onOffset varchar := null)
{
  if (isnull (onOffset)) {
  delete from CAL.WA.EVENTS where E_ID = id and E_DOMAIN_ID = domain_id;
  } else {
    declare eExceptions any;

    onOffset := '<' || cast (onOffset as varchar) || '>';
    eExceptions := (select E_REPEAT_EXCEPTIONS from CAL.WA.EVENTS where E_ID = id and E_DOMAIN_ID = domain_id);
    if (isnull (strstr (eExceptions, onOffset)))
      update CAL.WA.EVENTS
         set E_REPEAT_EXCEPTIONS = eExceptions || ' ' || onOffset
       where E_ID = id and
             E_DOMAIN_ID = domain_id;
  }
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.event_gmt2user (
  in pDate datetime,
  in pTimezone integer := 0)

{
  if (isnull (pDate))
    return pDate;
  return dateadd ('minute', pTimezone, pDate);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.event_user2gmt (
  in pDate datetime,
  in pTimezone integer := 0)
{
  if (isnull (pDate))
    return pDate;
  return dateadd ('minute', -pTimezone, pDate);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.event_occurAtDate (
  in pDate datetime,
  in event integer,
  in eventStart datetime,
  in eventRepeat varchar,
  in eventRepeatParam1 integer,
  in eventRepeatParam2 integer,
  in eventRepeatParam3 integer,
  in eventRepeatUntil datetime,
  in eventRepeatExceptions varchar,
  in weekStarts varchar := 'm')
{
  declare tmp any;

  -- before start date
  if (event = 1)
    eventStart := dateadd ('hour', -12, eventStart);

  if (pDate < eventStart)
    return 0;

  -- after until date
  if ((not isnull (eventRepeatUntil)) and (pDate > eventRepeatUntil))
    return 0;

  -- deleted occurence
  if (not isnull (strstr (eventRepeatExceptions, '<' || cast (datediff ('day', eventStart, pDate) as varchar) || '>')))
    return 0;

  -- Every N-th day(s)
  if (eventRepeat = 'D1') {
    if (mod (datediff ('day', eventStart, pDate), eventRepeatParam1) = 0)
      return 1;
  }

  -- Every week day
  if (eventRepeat = 'D2') {
    tmp := dayofweek (pDate);
    if ((tmp > 1) and (tmp < 7))
      return 1;
  }

  -- Every N-th week on ...
  if (eventRepeat = 'W1') {
    if (mod (datediff ('day', dateadd ('day', 7, CAL.WA.dt_EndOfWeek (eventStart, weekStarts)), pDate) / 7, eventRepeatParam1) = 0)
      if (bit_and (eventRepeatParam2, power (2, CAL.WA.dt_WeekDay (pDate, weekStarts)-1)))
        return 1;
  }

  -- Every N-th day of M-th month(s)
  if (eventRepeat = 'M1') {
    tmp := datediff ('month', CAL.WA.dt_BeginOfMonth (eventStart), pDate);
    if ((tmp <> 0) and (mod (tmp, eventRepeatParam2) = 0))
      if (dayofmonth (pDate) = eventRepeatParam1)
        return 1;
  }

  -- Every X day/weekday/wekkend/... of Y-th month(s)
  if (eventRepeat = 'M2') {
    tmp := datediff ('month', CAL.WA.dt_BeginOfMonth (eventStart), pDate);
    if ((tmp <> 0) and (mod (tmp, eventRepeatParam3) = 0))
      if (dayofmonth (pDate) = CAL.WA.event_findDay (pDate, eventRepeatParam1, eventRepeatParam2))
        return 1;
  }

  if (eventRepeat = 'Y1') {
    if ((month (pDate) = eventRepeatParam1) and (dayofmonth (pDate) = eventRepeatParam2))
      return 1;
  }

  -- Every X day/weekday/wekkend/... of Y-th month(s)
  if (eventRepeat = 'Y2') {
    if (month (pDate) = eventRepeatParam3)
      if (dayofmonth (pDate) = CAL.WA.event_findDay (pDate, eventRepeatParam1, eventRepeatParam2))
        return 1;
  }

  return 0;
}
;

-------------------------------------------------------------------------------
--
-- return the day of the month defined with E_REPEAT_PARAM1 and E_REPEAT_PARAM2, when E_REPAEAT is 'M2' or 'Y2'
--
--------------------------------------------------------------------------------
create procedure CAL.WA.event_findDay (
  in pDate   date,
  in eventRepeatParam1 integer,
  in eventRepeatParam2 integer)
{
  declare N, pDay integer;

  pDay := dayofmonth (pDate);
  -- last (day|weekday|weekend|m|t|w|t|f|s|s)
  if (eventRepeatParam1 = 5) {
    pDate := CAL.WA.dt_EndOfMonth (pDate);
    while (not CAL.WA.event_testDayKind (pDate, eventRepeatParam2))
      pDate := dateadd ('day', -1, pDate);
    return dayofmonth (pDate);
  }

  pDate := CAL.WA.dt_BeginOfMonth (pDate);
  -- first|second|third|fourth (m|t|w|t|f|s|s)
  if (1 <= eventRepeatParam2 and eventRepeatParam2 <= 7) {
    while (not CAL.WA.event_testDayKind (pDate, eventRepeatParam2))
      pDate := dateadd ('day', 1, pDate);
    return dayofmonth (dateadd ('day', 7*(eventRepeatParam1-1), pDate));
  }

  -- first|second|third|fourth  (m|t|w|t|f|s|s) (day|weekday|weekend)
  if (1 <= eventRepeatParam1 and eventRepeatParam1 <= 4) {
    N := eventRepeatParam1;
    while (pDay >= dayofmonth (pDate)) {
      if (CAL.WA.event_testDayKind (pDate, eventRepeatParam2)) {
        N := N - 1;
        if (N = 0)
          return dayofmonth (pDate);
      }
      pDate := dateadd ('day', 1, pDate);
    }
  }

  return 0;
}
;


--------------------------------------------------------------------------------
--
-- check if day on pDate is of the kind specified with E_REPEAT_PARAM2
--
--------------------------------------------------------------------------------
create procedure CAL.WA.event_testDayKind (
  in pDate date,
  in eventRepeatParam integer)
{
  if (eventRepeatParam = 10) -- any day
    return 1;

  declare weekDay integer;

  weekDay := CAL.WA.dt_WeekDay (pDate);
  -- weekday
  if (eventRepeatParam = 11)
    return either (gte (weekDay,6), 0, 1);

  -- weekend
  if (eventRepeatParam = 12)
    return either (gte (weekDay,6), 1, 0);

  return equ (weekDay, eventRepeatParam);
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.events_forPeriod (
  in domain_id integer,
  in pDateStart date,
  in pDateEnd date,
  in pTimezone integer,
  in pWeekStarts varchar := 'm')
{
  declare dt date;
  declare dt_offset integer;

  declare c0, c1, c6, c7 integer;
  declare c2, c5 varchar;
  declare c3, c4 datetime;
  result_names (c0, c1, c2, c3, c4, c5, c6, c7);

  pDateStart := CAL.WA.event_user2gmt (CAL.WA.dt_dateClear (pDateStart), pTimezone);
  pDateEnd := CAL.WA.event_user2gmt (dateadd ('day', 1, CAL.WA.dt_dateClear (pDateEnd)), pTimezone);

  -- regular events
  for (select E_ID,
              E_EVENT,
              E_SUBJECT,
              E_EVENT_START,
              E_EVENT_END,
              E_REPEAT,
              E_REMINDER
         from CAL.WA.EVENTS
        where E_DOMAIN_ID = domain_id
          and E_REPEAT = ''
          and E_EVENT_START >= pDateStart
          and E_EVENT_START <  pDateEnd) do
  {
    result (E_ID,
            E_EVENT,
            E_SUBJECT,
            CAL.WA.event_gmt2user (E_EVENT_START, pTimezone),
            CAL.WA.event_gmt2user (E_EVENT_END, pTimezone),
            E_REPEAT,
            null,
            E_REMINDER);
  }

  -- repetable events
  for (select E_ID,
              E_SUBJECT,
              E_EVENT,
              E_EVENT_START,
              E_EVENT_END,
              E_REPEAT,
              E_REPEAT_PARAM1,
              E_REPEAT_PARAM2,
              E_REPEAT_PARAM3,
              E_REPEAT_UNTIL,
              E_REPEAT_EXCEPTIONS,
              E_REMINDER
         from CAL.WA.EVENTS
        where E_DOMAIN_ID = domain_id
          and E_REPEAT <> ''
          and E_EVENT_START <  pDateEnd
          and ((E_REPEAT_UNTIL is null) or (E_REPEAT_UNTIL <  pDateEnd))) do
  {
    dt := pDateStart;
    while (dt < pDateEnd) {
      if (CAL.WA.event_occurAtDate (dt,
                                    E_EVENT,
                                    E_EVENT_START,
                                    E_REPEAT,
                                    E_REPEAT_PARAM1,
                                    E_REPEAT_PARAM2,
                                    E_REPEAT_PARAM3,
                                    E_REPEAT_UNTIL,
                                    E_REPEAT_EXCEPTIONS,
                                    pWeekStarts)) {
        if (E_EVENT = 1) {
          dt_offset := datediff ('day', dateadd ('hour', -12, E_EVENT_START), dt);
        } else {
          dt_offset := datediff ('day', E_EVENT_START, dt);
        }
        result (E_ID,
                E_EVENT,
                E_SUBJECT,
                CAL.WA.event_gmt2user (dateadd ('day', dt_offset, E_EVENT_START), pTimezone),
                CAL.WA.event_gmt2user (dateadd ('day', dt_offset, E_EVENT_END), pTimezone),
                E_REPEAT,
                dt_offset,
                E_REMINDER);
      }
      dt := dateadd ('day', 1, dt);
    }
  }
}
;

-------------------------------------------------------------------------------
--
create procedure CAL.WA.events_forDate (
  in domain_id integer,
  in pDate date,
  in pTimezone integer,
  in pWeekStarts varchar := 'm')
{
  return CAL.WA.events_forPeriod (domain_id, pDate, pDate, pTimezone, pWeekStarts);
}
;

-----------------------------------------------------------------------------------------
--
-- Tasks
--
-----------------------------------------------------------------------------------------
create procedure CAL.WA.task_update (
  in id integer,
  in domain_id integer,
  in subject varchar,
  in description varchar,
  in tags varchar,
  in eventStart datetime,
  in eventEnd datetime,
  in priority integer,
  in status varchar,
  in complete integer)
{
  if (id = -1) {
    id := sequence_next ('CAL.WA.event_id');
    insert into CAL.WA.EVENTS
      (
        E_ID,
        E_DOMAIN_ID,
        E_KIND,
        E_SUBJECT,
        E_DESCRIPTION,
        E_TAGS,
        E_EVENT_START,
        E_EVENT_END,
        E_PRIORITY,
        E_STATUS,
        E_COMPLETE,
        E_CREATED,
        E_UPDATED
      )
      values
      (
        id,
        domain_id,
        1,
        subject,
        description,
        tags,
        eventStart,
        eventEnd,
        priority,
        status,
        complete,
        now (),
        now ()
      );
  } else {
    update CAL.WA.EVENTS
       set E_SUBJECT = subject,
           E_DESCRIPTION = description,
           E_TAGS = tags,
           E_EVENT_START = eventStart,
           E_EVENT_END = eventEnd,
           E_PRIORITY = priority,
           E_STATUS = status,
           E_COMPLETE = complete,
           E_UPDATED = now ()
     where E_ID = id and
           E_DOMAIN_ID = domain_id;
  }
  return id;
}
;

-----------------------------------------------------------------------------------------
--
-- Notes
--
-----------------------------------------------------------------------------------------
create procedure CAL.WA.note_update (
  in id integer,
  in domain_id integer,
  in subject varchar,
  in description varchar,
  in tags varchar)
{
  if (id = -1) {
    id := sequence_next ('CAL.WA.event_id');
    insert into CAL.WA.EVENTS
      (
        E_ID,
        E_DOMAIN_ID,
        E_KIND,
        E_SUBJECT,
        E_DESCRIPTION,
        E_TAGS,
        E_CREATED,
        E_UPDATED
      )
      values
      (
        id,
        domain_id,
        2,
        subject,
        description,
        tags,
        now (),
        now ()
      );
  } else {
    update CAL.WA.EVENTS
       set E_SUBJECT = subject,
           E_DESCRIPTION = description,
           E_TAGS = tags,
           E_UPDATED = now ()
     where E_ID = id and
           E_DOMAIN_ID = domain_id;
  }
  return id;
}
;

-------------------------------------------------------------------------------
--
-- Searches
--
-------------------------------------------------------------------------------
create procedure CAL.WA.search_sql (
  inout domain_id integer,
  inout account_id integer,
  inout data varchar)
{
  declare S, tmp, where2, delimiter2 varchar;

  where2 := ' \n ';
  delimiter2 := '\n and ';

  S := ' select          \n' ||
       ' E_ID,           \n' ||
       ' E_DOMAIN_ID,    \n' ||
       ' E_KIND,         \n' ||
       ' E_SUBJECT,      \n' ||
       ' E_EVENT,        \n' ||
       ' E_EVENT_START,  \n' ||
       ' E_EVENT_END,    \n' ||
       ' E_REPEAT,       \n' ||
       ' E_REMINDER,     \n' ||
       ' E_CREATED,      \n' ||
       ' E_UPDATED       \n' ||
       ' from            \n' ||
       '   CAL.WA.EVENTS \n' ||
       ' where E_DOMAIN_ID = <DOMAIN_ID> <TEXT> <TAGS> <WHERE> \n';

  tmp := CAL.WA.xml_get ('keywords', data);
  if (not is_empty_or_null (tmp)) {
    S := replace (S, '<TEXT>', sprintf('and contains (E_SUBJECT, \'[__lang "x-ViDoc"] %s\') \n', FTI_MAKE_SEARCH_STRING (tmp)));
  } else {
    tmp := CAL.WA.xml_get ('expression', data);
    if (not is_empty_or_null(tmp))
      S := replace (S, '<TEXT>', sprintf('and contains (E_SUBJECT, \'[__lang "x-ViDoc"] %s\') \n', tmp));
  }

  tmp := CAL.WA.xml_get ('tags', data);
  if (not is_empty_or_null (tmp)) {
    tmp := CAL.WA.tags2search (tmp);
    S := replace (S, '<TAGS>', sprintf ('and contains (E_SUBJECT, \'[__lang "x-ViDoc"] %s\') \n', tmp));
  }

  S := replace (S, '<DOMAIN_ID>', cast (domain_id as varchar));
  S := replace (S, '<ACCOUNT_ID>', cast (account_id as varchar));
  S := replace (S, '<TAGS>', '');
  S := replace (S, '<TEXT>', '');
  S := replace (S, '<WHERE>', where2);

  --dbg_obj_print(S);
  return S;
}
;

-----------------------------------------------------------------------------------------
--
create procedure CAL.WA.version_update ()
{
  for (select WAI_ID, WAM_USER
         from DB.DBA.WA_MEMBER
                join DB.DBA.WA_INSTANCE on WAI_NAME = WAM_INST
        where WAI_TYPE_NAME = 'Calendar'
          and WAM_MEMBER_TYPE = 1) do {
    CAL.WA.domain_update (WAI_ID, WAM_USER);
  }
}
;

-----------------------------------------------------------------------------------------
--
CAL.WA.version_update ()
;
