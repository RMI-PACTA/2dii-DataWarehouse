BEGIN;
CREATE TEMPORARY TABLE name_abbreviation_tests (
    test_string TEXT UNIQUE NOT NULL,
    expected TEXT NOT NULL,
    description TEXT
  );

  INSERT INTO name_abbreviation_tests (
    test_string,
    expected,
    description
  ) VALUES
  /* \s+and\s+ */
  ('this and that', 'this & that', '''and'' to ampersand'),
  ('THIS AND THAT', 'THIS & THAT', '''and'' case-insensitive'),
  ('this  and  that', 'this & that', '''and'' with multiple spaces'),
  ('this	and that', 'this & that', '''and'' with tab before'),
  ('bandcamp', 'bandcamp', '''and'' in middle of word not replaced'),
  ('band camp', 'band camp', '''and'' at end of word not replaced'),
  ('robot android', 'robot android', '''and'' at beginning of word not replaced'),
  ('and more', 'and more', '''and'' at beginning of string not replaced (~* ^and\s)'),
  ('foo and', 'foo and', '''and'' at end of string not replaced (~* \sand$)'),
  /* \s+en\s+ */
  ('dit en dat', 'dit & dat', '''en'' to ampersand'),
  ('DIT EN DAT', 'DIT & DAT', '''en'' to ampersand'),
  ('Levenshtein', 'Levenshtein', '''en'' in middle of word not replaced'),
  ('dit	en  dat', 'dit & dat', '''en'' with spacings'),
  ('ten thousand', 'ten thousand', '''en'' at end of word not replaced'),
  ('The End', 'The End', '''en'' at beginning of word not replaced'),
  ('en more', 'en more', '''en'' at beginning of string not replaced (~* ^en\s)'),
  ('foo en', 'foo en', '''en'' at end of string not replaced (~* \sen$)'),
  /* \s+och\s+ */
  ('A och B', 'A & B', '''och'' to ampersand'),
  ('A OCH B', 'A & B', '''och'' case-insensitive'),
  ('A	och  B', 'A & B', '''och'' alternative_spacing'),
  ('Sochi', 'Sochi', '''och'' in middle of word not replaced'),
  ('tengo ocho llamas', 'tengo ocho llamas', '''och'' at beginning of word not replaced'),
  ('Loch Ness', 'Loch Ness', '''och'' at end of word not replaced'),
  ('och more', 'och more', '''och'' at beginning of string not replaced (~* ^och\s)'),
  ('foo och', 'foo och', '''och'' at end of string not replaced (~* \soch$)'),
  /* \s+und\s+ */
  ('A und B', 'A & B', '''und'' to ampersand'),
  ('A UND B', 'A & B', '''und'' case-insensitive'),
  ('A	und  B', 'A & B', '''und'' alternative_spacing'),
  ('Bundesliga', 'Bundesliga', '''und'' in middle of word not replaced'),
  ('towed under', 'towed under', '''und'' at beginning of word not replaced'),
  ('fund manager', 'fund manager', '''und'' at end of word not replaced'),
  ('und more', 'und more', '''und'' at beginning of string not replaced (~* ^und\s)'),
  ('foo und', 'foo und', '''und'' at end of string not replaced (~* \sund$)'),
  /* ampersand */
  ('this & that', 'this & that', 'ampersand does not change'),
  /* (inactive) */
  ('noparens inactive', 'noparens inactive', '''inactive'' without parens not replaced'),
  ('foobar(inactive)', 'foobar', NULL),
  ('foobar (inactive)', 'foobar ', '''(inactive)'' with spaces does not remove spaces'),
  ('foobar	(inactive)', 'foobar	', '''inactive'' with tabs'),
  ('(inactive) outdated organization', ' outdated organization', '''(inactive)'' at beginning of string does not replace space'),
  ('inactive outdated organization', 'inactive outdated organization', '''inactive'' without parens not replaced'),
  /* aktg */
  ('foobar aktg', 'foobar$ag', NULL),
  ('foobar-aktg', 'foobar-ag', NULL),
  ('Foobar AKTG', 'Foobar$ag', NULL),
  ('foo aktg bar', 'foo ag bar', NULL),
  ('baraktgfoo', 'baragfoo', NULL),
  /* aktiengesellschaft */
  ('foobar aktiengesellschaft', 'foobar$ag', NULL),
  ('foobar-aktiengesellschaft', 'foobar-ag', NULL),
  ('Foobar AKTIENGESELLSCHAFT', 'Foobar$ag', NULL),
  ('Foobar Aktiengesellschaft', 'Foobar$ag', NULL),
  ('foo aktiengesellschaft bar', 'foo ag bar', NULL),
  ('baraktiengesellschaftfoo', 'baragfoo', NULL),
  /* associate */
  ('testing associate', 'testing assoc', '''associate'' reduces to assoc'),
  ('Testing Associate', 'Testing assoc', NULL),
  ('foo, bar, & associate', 'foo, bar, & assoc', NULL),
  ('Foo, Bar, & Associate', 'Foo, Bar, & assoc', NULL),
  /* associated, Note the d at the end. */
  ('Associated Media', 'assocd Media', '''associated'' reduces to assocd'),
  ('foo associate bar', 'foo assoc bar', NULL),
  /* associates */
  ('testing associates', 'testing assoc', '''associates'' reduces to assoc'),
  ('Testing Associates', 'Testing assoc', NULL),
  ('foo, bar, & associates', 'foo, bar, & assoc', NULL),
  ('Foo, Bar, & Associates', 'Foo, Bar, & assoc', NULL),
  /* berhad */
  ('foobar berhad', 'foobar$bhd', NULL),
  ('Foobar Berhad', 'Foobar$bhd', NULL),
  ('foo berhad bar', 'foo bhd bar', NULL),
  ('fooberhadbar', 'foobhdbar', NULL),
  /* company */
  ('foobar company', 'foobar$co', NULL),
  ('FooBar Company', 'FooBar$co', NULL),
  ('foo company bar', 'foo co bar', NULL),
  ('Foo Company Bar', 'Foo co Bar', NULL),
  ('Company Foobar', 'co Foobar', NULL),
  ('Foo BarCompany', 'Foo Barco', '~* company, !~* \scompany'),
  ('foo barcompany', 'foo barco', NULL),
  ('foobar companies', 'foobar companies', 'companies - plural'),
  ('Foobar Companies', 'Foobar Companies', 'Companies - plural'),
  ('foobar companhia', 'foobar companhia', 'companhia'),
  ('foobar compania', 'foobar compania', 'compania'),
  ('foobar companie', 'foobar companie', 'companie'),
  /* corporation */
  ('foobar corporation', 'foobar$corp', NULL),
  ('FooBar Corporation', 'FooBar$corp', NULL),
  ('foobar corporation private', 'foobar corp private', NULL),
  ('FooBar Corporation Private', 'FooBar corp Private', NULL),
  ('foobar (corporation)', 'foobar (corp)', NULL),
  ('corporation foobar', 'corp foobar', NULL),
  ('foobar bancorporation', 'foobar bancorp', NULL),
  ('foobar incorporation', 'foobar incorp', NULL),
  /* designated\s+activity\s+company */
  ('foobar designated activity company', 'foobar$dac', NULL),
  ('Foobar Designated Activity Company', 'Foobar$dac', NULL),
  ('foobar designated activity co', 'foobar$dac', 'company collapses to co'),
  ('Foobar Designated Activity Co', 'Foobar$dac', 'company collapses to co'),
  /* develop */
  ('foobar develop', 'foobar dev', NULL),
  ('FooBar Develop', 'FooBar dev', NULL),
  ('develop foobar', 'dev foobar', NULL),
  ('foo develop bar', 'foo dev bar', NULL),
  ('idevelop foobar', 'idev foobar', NULL),
  ('foobar developer', 'foobar dever', NULL),
  ('foobar developers', 'foobar devers', NULL),
  ('foobar developing', 'foobar deving', NULL),
  ('foobar developed', 'foobar deved', NULL),
  /* development */
  ('foobar development', 'foobar dev', NULL),
  ('FooBar Development', 'FooBar dev', NULL),
  ('foo development bar', 'foo dev bar', NULL),
  ('development foobar', 'dev foobar', NULL),
  ('foobar developments', 'foobar devs', NULL),
  ('developments foobar', 'devs foobar', NULL),
  ('foo (development) bar', 'foo (dev) bar', NULL),
  ('foo (developments) bar', 'foo (devs) bar', NULL),
  ('foodevelopment bar', 'foodev bar', NULL),
  ('foo redevelopment bar', 'foo redev bar', NULL),
  ('Foobar Developpement', 'Foobar devpement', 'Developpement - 2 p'),
  ('foobar developpement', 'foobar devpement', 'developpement - 2 p'),
  ('foobar redevelopement', 'foobar redevement', 'developement - additional e'),
  /* financial */
  ('foobar financial', 'foobar fin', NULL),
  ('FooBar Financial', 'FooBar fin', NULL),
  ('foobar financial services', 'foobar fin services', NULL),
  ('financial foobar', 'fin foobar', NULL),
  ('Financial Foobar', 'fin Foobar', NULL),
  ('foo financials bar', 'foo fins bar', 'financials - s at the end'),
  ('foofinancial bar', 'foofin bar', NULL),
  ('foofinancialbar', 'foofinbar', NULL),
  /* generation */
  ('foobar generation', 'foobar gen', NULL),
  ('FooBar Generation', 'FooBar gen', NULL),
  ('foobargeneration', 'foobargen', NULL),
  ('generation foobar', 'gen foobar', NULL),
  ('foo generation bar', 'foo gen bar', NULL),
  ('foo generations bar', 'foo gens bar', 'generations - plural'),
  ('foo cogeneration bar', 'foo cogen bar', 'cogeneration'),
  ('foo co-generation bar', 'foo co-gen bar', 'cogeneration'),
  /* government */
  ('foobar government', 'foobar$govt', NULL),
  ('FooBar Government', 'FooBar$govt', NULL),
  ('Foo Government Department of Bar', 'Foo govt Department of Bar', NULL),
  ('Government of Foobar', 'govt of Foobar', NULL),
  ('government of foobar', 'govt of foobar', NULL),
  ('foo government bar', 'foo govt bar', NULL),
  ('foo intergovernment bar', 'foo intergovt bar', 'intergovernment'),
  ('foo governments bar', 'foo govts bar', 'governments'),
  ('foo governmental bar', 'foo govtal bar', 'governmental'),
  ('foo intergovernmental bar', 'foo intergovtal bar', 'intergovernmental'),
  ('foo governmentbar', 'foo govtbar', NULL),
  /* group */
  ('foobar group', 'foobar grp', NULL),
  ('FooBar Group', 'FooBar grp', NULL),
  ('group foobar', 'grp foobar', NULL),
  ('Group FooBar', 'grp FooBar', NULL),
  ('foo group bar', 'foo grp bar', NULL),
  ('foo (group) bar', 'foo (grp) bar', NULL),
  ('Foo Group Bar', 'Foo grp Bar', NULL),
  ('foogroup bar', 'foogrp bar', NULL),
  ('foo-group bar', 'foo-grp bar', NULL),
  ('foo groupbar', 'foo grpbar', NULL),
  ('FooBar Groups', 'FooBar grps', 'groups - plural'),
  ('Groupe FooBar', 'grpe FooBar', 'groupe - e'),
  ('Groupement FooBar', 'grpement FooBar', 'groupement - ement'),
  ('Groupama', 'grpama', 'groupama - ama'),
  /* holding */
  ('foobar holding', 'foobar$hldgs', NULL),
  ('FooBar Holding', 'FooBar$hldgs', NULL),
  ('foo holding bar', 'foo hldgs bar', NULL),
  ('Holding Foobar', 'hldgs Foobar', NULL),
  ('Holdingfoo bar', 'hldgsfoo bar', NULL),
  ('Fooholdingbar', 'Foohldgsbar', NULL),
  ('Foo Shipholding bar', 'Foo Shiphldgs bar', NULL),
  ('Foo Energoholding bar', 'Foo Energohldgs bar', NULL),
  ('Foo Shareholding bar', 'Foo Sharehldgs bar', NULL),
  ('Foo Industrieholding bar', 'Foo Industriehldgs bar', NULL),
  ('Foo Stockholding bar', 'Foo Stockhldgs bar', NULL),
  ('Foo Topholding bar', 'Foo Tophldgs bar', NULL),
  ('Foo Muniholding bar', 'Foo Munihldgs bar', NULL),
  ('Foo Wingholding bar', 'Foo Winghldgs bar', NULL),
  /* holdings */
  ('foobar holdings', 'foobar$hldgs', NULL),
  ('FooBar Holdings', 'FooBar$hldgs', NULL),
  ('foo holdings bar', 'foo hldgs bar', NULL),
  ('Holdings Foobar', 'hldgs Foobar', NULL),
  ('Holdingsfoo bar', 'hldgsfoo bar', NULL),
  ('Fooholdings bar', 'Foohldgs bar', NULL),
  ('Foo Shipholdings bar', 'Foo Shiphldgs bar', NULL),
  ('FooBar (Holdings)', 'FooBar (hldgs)', NULL),
  ('foo (holdings) bar', 'foo (hldgs) bar', NULL),
  /* incorporated */
  ('foobar incorporated', 'foobar$inc', NULL),
  ('FooBar Incorporated', 'FooBar$inc', NULL),
  ('Foo Incorporated Bar', 'Foo inc Bar', NULL),
  /* international */
  ('foobar international', 'foobar$intl', NULL),
  ('FooBar International', 'FooBar$intl', NULL),
  ('foo international bar', 'foo intl bar', NULL),
  ('Foo International Bar', 'Foo intl Bar', NULL),
  ('International Foobar', 'intl Foobar', NULL),
  ('Internationale Foobar', 'intle Foobar', 'Internationale - e'),
  ('Foobar-International', 'Foobar-intl', NULL),
  /* investment */
  ('foobar investment', 'foobar invest', NULL),
  ('FooBar Investment', 'FooBar invest', NULL),
  ('foo investment bar', 'foo invest bar', NULL),
  ('Foo Investment Bar', 'Foo invest Bar', NULL),
  ('foo investments bar', 'foo invests bar', 'investments - plural'),
  ('foo investmentfonds bar', 'foo investfonds bar', 'investmentfonds'),
  ('Foo Co-Investment Bar', 'Foo Co-invest Bar', NULL),
  /* limited */
  ('foobar limited', 'foobar$ltd', NULL),
  ('Foobar Limited', 'Foobar$ltd', NULL),
  ('Limited Foobar', 'ltd Foobar', NULL),
  ('Foo Limited Bar', 'Foo ltd Bar', NULL),
  ('Foo Unlimited Bar', 'Foo Unltd Bar', NULL),
  /* partner */
  ('foobar partner', 'foobar prt', NULL),
  ('FooBar Partner', 'FooBar prt', NULL),
  ('foo partner bar', 'foo prt bar', NULL),
  ('Foo Partner Bar', 'Foo prt Bar', NULL),
  ('Foo Multipartner Bar', 'Foo Multiprt Bar', 'Multipartner'),
  ('Foo Partnerre Bar', 'Foo prtre Bar', 'Partnerre'),
  ('Foo Aviapartner Bar', 'Foo Aviaprt Bar', 'Aviapartner'),
  ('Foopartner Bar', 'Fooprt Bar', NULL),
  ('Foo Partnerbar', 'Foo prtbar', NULL),
  ('Foopartnerbar', 'Fooprtbar', NULL),
  /* partners */
  ('foobar partners', 'foobar prt', NULL),
  ('FooBar Partners', 'FooBar prt', NULL),
  ('foo partners bar', 'foo prt bar', NULL),
  ('Foo Partners Bar', 'Foo prt Bar', NULL),
  ('Partners Foobar', 'prt Foobar', NULL),
  ('foobar partnership', 'foobar prthip', 'partnership'),
  ('foobar partnerships', 'foobar prthips', 'partnerships - plural'),
  ('foopartners bar', 'fooprt bar', '~* \Spartners'),
  ('foo-partners bar', 'foo-prt bar', '~* \Spartners'),
  /* resource */
  ('foobar resource', 'foobar res', NULL),
  ('Foobar Resource', 'Foobar res', NULL),
  ('Resource Foobar', 'res Foobar', NULL),
  ('Foo Resource Bar', 'Foo res Bar', NULL),
  ('Fooresource Bar', 'Foores Bar', NULL),
  ('Foo Resourceful Bar', 'Foo resful Bar', 'Resourceful'),
  /* resources */
  ('foobar resources', 'foobar res', NULL),
  ('Foobar Resources', 'Foobar res', NULL),
  ('Resources Foobar', 'res Foobar', NULL),
  ('Foo Resources Bar', 'Foo res Bar', NULL),
  ('Fooresources Bar', 'Foores Bar', NULL),
  ('Foobar Petroresources', 'Foobar Petrores', 'Petroresources'),
  /* shipping */
  ('foobar shipping', 'foobar shp', NULL),
  ('Foobar Shipping', 'Foobar shp', NULL),
  ('shipping Foobar', 'shp Foobar', NULL),
  ('Foo shipping Bar', 'Foo shp Bar', NULL),
  ('Foo Intershipping Bar', 'Foo Intershp Bar', 'Intershipping'),
  ('Foo Shipping-Bar', 'Foo shp-Bar', NULL),
  /* limited\s+partnership */
  ('foobar limited partnership', 'foobar$lp', NULL),
  ('Foobar Limited Partnership', 'Foobar$lp', NULL),
  ('Foo Limited Partnership Bar', 'Foo lp Bar', NULL),
  ('foobar ltd partnership', 'foobar$lp', NULL),
  ('Foobar Ltd Partnership', 'Foobar$lp', NULL),
  ('Foo Ltd Partnership Bar', 'Foo lp Bar', NULL),
  ('foobar ltd partners', 'foobar ltd prt', NULL),
  ('Foo Ltd Partners Bar', 'Foo Ltd prt Bar', NULL),
  ('Foobar Partners Ltd', 'Foobar prt$ltd', NULL),
  ('Foobar Partners Limited', 'Foobar prt$ltd', NULL),
  ('Foobar Partnership Ltd', 'Foobar prthip$ltd', NULL),
  ('Foobar Partnership Limited', 'Foobar prthip$ltd', NULL),
  /* public\s+ltd\s+co */
  ('foobar public limited company', 'foobar$plc', NULL),
  ('Foobar Public Limited Company', 'Foobar$plc', NULL),
  ('foobar public limited co', 'foobar$plc', NULL),
  ('Foobar Public Limited Co', 'Foobar$plc', NULL),
  ('foobar public ltd company', 'foobar$plc', NULL),
  ('Foobar Public Ltd Company', 'Foobar$plc', NULL),
  ('Foobar Public Company Limited', 'Foobar Public co$ltd', NULL),
  ('Foobar Company Public Limited', 'Foobar co Public$ltd', NULL),
  ('Foobar Company Limited Public', 'Foobar co ltd Public', NULL),
  ('Foobar Limited Public Company', 'Foobar ltd Public$co', NULL),
  ('Foobar Limited Company Public', 'Foobar ltd co Public', NULL),
  /* ltd\s+liability\s+co */
  ('foobar limited liability company', 'foobar$llc', NULL),
  ('Foobar Limited Liability Company', 'Foobar$llc', NULL),
  ('foobar limited liability co', 'foobar$llc', NULL),
  ('Foobar Limited Liability Co', 'Foobar$llc', NULL),
  ('foobar ltd liability company', 'foobar$llc', NULL),
  ('Foobar Ltd Liability Company', 'Foobar$llc', NULL),
  ('Foobar Limited Company Liability', 'Foobar ltd co Liability', NULL),
  ('Foobar Liability Limited Company', 'Foobar Liability ltd$co', NULL),
  ('Foobar Liability Company Limited', 'Foobar Liability co$ltd', NULL),
  ('Foobar Company Liability Limited', 'Foobar co Liability$ltd', NULL),
  ('Foobar Company Limited Liability', 'Foobar co ltd Liability', NULL),
  /* \s+ag$ */
  ('foobar ag', 'foobar$ag', NULL),
  ('FooBar AG', 'FooBar$ag', NULL),
  ('FooBar	AG', 'FooBar$ag', 'tab whitespace'),
  ('big bag', 'big bag', 'ag suffix must have space before.'),
  ('foo ag bar', 'foo ag bar', NULL),
  ('foobar ag ag', 'foobar ag$ag', NULL),
  ('fooag bar', 'fooag bar', NULL),
  ('foo agbar', 'foo agbar', NULL),
  ('fooagbar', 'fooagbar', NULL),
  ('ag foobar', 'ag foobar', NULL),
  /* \s+as$ */
  ('foobar as', 'foobar$as', NULL),
  ('Foobar As', 'Foobar$as', NULL),
  ('foobar gas', 'foobar gas', 'as at end needs space before'),
  ('foobaras', 'foobaras', NULL),
  ('foo as bar', 'foo as bar', NULL),
  ('fooas bar', 'fooas bar', NULL),
  ('foo asbar', 'foo asbar', NULL),
  ('fooasbar', 'fooasbar', NULL),
  ('as foobar', 'as foobar', NULL),
  /* \s+asa$ */
  ('foobar asa', 'foobar$asa', NULL),
  ('Foobar Asa', 'Foobar$asa', NULL),
  ('Foobar Perkasa', 'Foobar Perkasa', 'Perkasa'),
  ('foobarasa', 'foobarasa', NULL),
  ('foo asa bar', 'foo asa bar', NULL),
  ('fooasa bar', 'fooasa bar', NULL),
  ('foo asabar', 'foo asabar', NULL),
  ('fooasabar', 'fooasabar', NULL),
  ('asa foobar', 'asa foobar', NULL),
  /* \s+bhd$ */
  ('foobar bhd', 'foobar$bhd', NULL),
  ('Foobar Bhd', 'Foobar$bhd', NULL),
  ('Foobar	Bhd', 'Foobar$bhd', 'tab whitespace'),
  ('foobhdbar', 'foobhdbar', NULL),
  ('foo bhd bar', 'foo bhd bar', NULL),
  ('foobhd bar', 'foobhd bar', NULL),
  ('foo bhdbar', 'foo bhdbar', NULL),
  ('bhd foobar', 'bhd foobar', NULL),
  /* \s+bsc$ */
  ('foobar bsc', 'foobar$bsc', NULL),
  ('Foobar Bsc', 'Foobar$bsc', NULL),
  ('foobarbsc', 'foobarbsc', NULL),
  ('foo bsc bar', 'foo bsc bar', NULL),
  ('foobsc bar', 'foobsc bar', NULL),
  ('foo bscbar', 'foo bscbar', NULL),
  ('foobscbar', 'foobscbar', NULL),
  ('bsc foobar', 'bsc foobar', NULL),
  /* \s+bv$ */
  ('foobar bv', 'foobar$bv', NULL),
  ('Foobar Bv', 'Foobar$bv', NULL),
  ('foobarbv', 'foobarbv', NULL),
  ('foo bv bar', 'foo bv bar', NULL),
  ('foobv bar', 'foobv bar', NULL),
  ('foo bvbar', 'foo bvbar', NULL),
  ('foobvbar', 'foobvbar', NULL),
  ('bv foobar', 'bv foobar', NULL),
  ('Foobar Bvi', 'Foobar Bvi', 'Bvi'),
  ('Foobar Ibv', 'Foobar Ibv', 'Ibv'),
  /* \s+co$ */
  ('foobar co', 'foobar$co', NULL),
  ('Foobar Co', 'Foobar$co', NULL),
  ('Foobar	Co', 'Foobar$co', 'tab whitespace'),
  ('foocobar', 'foocobar', NULL),
  ('foo co bar', 'foo co bar', NULL),
  /* \s+corp$ */
  ('foobar corp', 'foobar$corp', NULL),
  ('Foobar Corp', 'Foobar$corp', NULL),
  ('Foobar	Corp', 'Foobar$corp', 'tab whitespace'),
  ('Foocorp', 'Foocorp', 'replacing a suffix needs whitespace'),
  ('corpFoo', 'corpFoo', NULL),
  ('Scorpion', 'Scorpion', 'do not replace corp in middle of word'),
  ('foo corp bar', 'foo corp bar',  'do not replace corp in middle of string'),
  /* \s+cv$ */
  ('foobar cv', 'foobar$cv', NULL),
  ('Foobar Cv', 'Foobar$cv', NULL),
  ('foobar de cv', 'foobar de$cv', 'de cv'),
  ('Foobar De Cv', 'Foobar De$cv', 'De Cv'),
  ('Foobar Gcv', 'Foobar Gcv', '~* \Scv$'),
  ('Foobar Icv', 'Foobar Icv', 'Icv'),
  ('Foobar Cvba', 'Foobar Cvba', 'Cvba'),
  ('Cvfoo Bar', 'Cvfoo Bar',  '~* ^cv'),
  ('Cv Foo Bar', 'Cv Foo Bar',  '~* ^cv\s'),
  ('Foo Cvbar', 'Foo Cvbar',  '~* \scv\S'),
  ('Foo Cv Bar', 'Foo Cv Bar',  '~* \scv\s'),
  /* \s+dac$ */
  ('foobar dac', 'foobar$dac', NULL),
  ('Foobar Dac', 'Foobar$dac', NULL),
  ('Foobar	Dac', 'Foobar$dac', 'tab whitespace'),
  ('Big Bad Ac', 'Big Bad Ac', '''d ac'' does not replace on dac'),
  ('Foodac', 'Foodac', NULL),
  ('foo dac bar', 'foo dac bar', NULL),
  /* \s+govt$ */
  ('foobar govt', 'foobar$govt', NULL),
  ('foobar Govt', 'foobar$govt', NULL),
  ('foo govt dept of bar', 'foo govt dept of bar', NULL),
  ('govt of foobar', 'govt of foobar', NULL),
  ('foo intergovtl bar', 'foo intergovtl bar', 'intergovtl'),
  ('foobar govts', 'foobar govts', NULL),
  /* \s+hldgs$ */
  ('foobar hldgs', 'foobar$hldgs', NULL),
  ('foobar Hldgs', 'foobar$hldgs', NULL),
  ('Foo Hldgs Bar', 'Foo Hldgs Bar',  'hldgs in middle of string not altered'),
  ('foobar (Hldgs)', 'foobar (Hldgs)', 'hldgs in parens not altered'),
  ('foobar hldg', 'foobar hldg', 'hldg - no s'),
  ('foobar Hldg', 'foobar Hldg', 'hldg - no s'),
  ('Foo Hldg Bar', 'Foo Hldg Bar', 'hldg - no s'),
  ('Foo Shiphldg Bar', 'Foo Shiphldg Bar', 'hldg - no s'),
  /* \s+inc$ */
  ('foobar inc', 'foobar$inc', NULL),
  ('Foobar Inc', 'Foobar$inc', NULL),
  ('Foobar Zinc', 'Foobar Zinc', NULL),
  ('Foobar Dist Finc', 'Foobar Dist Finc', NULL),
  ('foo inc bar', 'foo inc bar', NULL),
  ('Incheon Foobar', 'Incheon Foobar', 'inc at start of string not replaced'),
  ('foo DaVinci bar', 'foo DaVinci bar', 'inc in middle of string not replaced'),
  /* \s+intl$ */
  ('foobar intl', 'foobar$intl', NULL),
  ('Foobar Intl', 'Foobar$intl', NULL),
  ('Intl Foobar', 'Intl Foobar', 'intl at beginning not altered'),
  ('foo intl bar', 'foo intl bar', 'intl in middle not altered'),
  ('Intlaero Foobar', 'Intlaero Foobar', 'intl at beginning not altered'),
  ('foointl bar', 'foointl bar', 'intl in middle not altered'),
  /* \s+llc$ */
  ('foobar llc', 'foobar$llc', NULL),
  ('Foobar Llc', 'Foobar$llc', NULL),
  ('Foo Llc Bar', 'Foo Llc Bar', NULL),
  ('Foollc Bar', 'Foollc Bar', NULL),
  ('Foo Llcbar', 'Foo Llcbar', NULL),
  ('Foollcbar', 'Foollcbar', NULL),
  ('Foobar Pllc', 'Foobar Pllc', 'Pllc'),
  /* \s+lp$ */
  ('foobar lp', 'foobar$lp', NULL),
  ('Foobar Lp', 'Foobar$lp', NULL),
  ('Foo Lp Bar', 'Foo Lp Bar', NULL),
  ('Foolp Bar', 'Foolp Bar', NULL),
  ('Foo Lpbar', 'Foo Lpbar', NULL),
  ('Foolpbar', 'Foolpbar', NULL),
  ('foobar llp', 'foobar llp', 'llp'),
  ('Foobar Llp', 'Foobar Llp', 'Llp'),
  /* \s+lt$ */
  ('foobar lt', 'foobar$ltd', NULL),
  ('Foobar Lt', 'Foobar$ltd', NULL),
  ('Foo Lt Bar', 'Foo Lt Bar', NULL),
  ('Foolt Bar', 'Foolt Bar', NULL),
  ('Foo Ltbar', 'Foo Ltbar', NULL),
  ('Fooltbar', 'Fooltbar', NULL),
  ('Foo Barlt', 'Foo Barlt', NULL),
  /* \s+ltd$ */
  ('foobar ltd', 'foobar$ltd', NULL),
  ('Foobar Ltd', 'Foobar$ltd', NULL),
  ('Foo Ltd Bar', 'Foo Ltd Bar', NULL),
  ('Fooltd Bar', 'Fooltd Bar', NULL),
  ('Foo Ltdbar', 'Foo Ltdbar', NULL),
  ('Fooltdbar', 'Fooltdbar', NULL),
  ('Foo Barltd', 'Foo Barltd', NULL),
  /* \s+nv$ */
  ('foobar nv', 'foobar$nv', NULL),
  ('Foobar Nv', 'Foobar$nv', NULL),
  ('Foo Nv Bar', 'Foo Nv Bar', NULL),
  ('Foonv Bar', 'Foonv Bar', NULL),
  ('Foo Nvbar', 'Foo Nvbar', NULL),
  ('Foonvbar', 'Foonvbar', NULL),
  ('Foo Barnv', 'Foo Barnv', NULL),
  ('Foobar Inv', 'Foobar Inv', 'Inv'),
  ('Foobar Sa/Nv', 'Foobar Sa/Nv', 'Sa/Nv'),
  /* \s+pcl$ */
  ('foobar pcl', 'foobar$pcl', NULL),
  ('Foobar Pcl', 'Foobar$pcl', NULL),
  ('Foo Pcl Bar', 'Foo Pcl Bar', NULL),
  ('Foopcl Bar', 'Foopcl Bar', NULL),
  ('Foo Pclbar', 'Foo Pclbar', NULL),
  ('Foopclbar', 'Foopclbar', NULL),
  ('Foo Barpcl', 'Foo Barpcl', NULL),
  /* \s+plc$ */
  ('foobar plc', 'foobar$plc', NULL),
  ('Foobar Plc', 'Foobar$plc', NULL),
  ('Foo Plc Bar', 'Foo Plc Bar', NULL),
  ('Fooplc Bar', 'Fooplc Bar', NULL),
  ('Foo Plcbar', 'Foo Plcbar', NULL),
  ('Fooplcbar', 'Fooplcbar', NULL),
  ('Foo Barplc', 'Foo Barplc', NULL),
  /* \s+pt$ */
  ('foobar pt', 'foobar$pt', NULL),
  ('Foobar Pt', 'Foobar$pt', NULL),
  ('Foo Pt Bar', 'Foo Pt Bar', NULL),
  ('Foopt Bar', 'Foopt Bar', NULL),
  ('Foo Ptbar', 'Foo Ptbar', NULL),
  ('Fooptbar', 'Fooptbar', NULL),
  ('Foo Barpt', 'Foo Barpt', NULL),
  /* \s+pte$ */
  ('foobar pte', 'foobar$pte', NULL),
  ('Foobar Pte', 'Foobar$pte', NULL),
  ('Foo Pte Bar', 'Foo Pte Bar', NULL),
  ('Foopte Bar', 'Foopte Bar', NULL),
  ('Foo Ptebar', 'Foo Ptebar', NULL),
  ('Fooptebar', 'Fooptebar', NULL),
  ('Foo Barpte', 'Foo Barpte', NULL),
  /* \s+sa$ */
  ('foobar sa', 'foobar$sa', NULL),
  ('Foobar Sa', 'Foobar$sa', NULL),
  ('Foo Sa Bar', 'Foo Sa Bar', NULL),
  ('Foosa Bar', 'Foosa Bar', NULL),
  ('Foo Sabar', 'Foo Sabar', NULL),
  ('Foosabar', 'Foosabar', NULL),
  ('Foo Barsa', 'Foo Barsa', NULL),
  ('Foobar Usa', 'Foobar Usa', 'Usa'),
  ('Foobar Sasu', 'Foobar Sasu', 'Sasu'),
  /* \s+sarl$ */
  ('foobar sarl', 'foobar$sarl', NULL),
  ('Foobar Sarl', 'Foobar$sarl', NULL),
  ('Foo Sarl Bar', 'Foo Sarl Bar', NULL),
  ('Foosarl Bar', 'Foosarl Bar', NULL),
  ('Foo Sarlbar', 'Foo Sarlbar', NULL),
  ('Foosarlbar', 'Foosarlbar', NULL),
  ('Foo Barsarl', 'Foo Barsarl', NULL),
  /* \s+sas$ */
  ('foobar sas', 'foobar$sas', NULL),
  ('Foobar Sas', 'Foobar$sas', NULL),
  ('Foobar Kansas', 'Foobar Kansas', '~* \Ssas$'),
  ('Foo Sas Bar', 'Foo Sas Bar', NULL),
  ('Foosas Bar', 'Foosas Bar', NULL),
  ('Foo Sasbar', 'Foo Sasbar', NULL),
  ('Foosasbar', 'Foosasbar', NULL),
  /* \s+se$ */
  ('foobar se', 'foobar$se', NULL),
  ('Foobar Se', 'Foobar$se', NULL),
  ('Foo Se Bar', 'Foo Se Bar', NULL),
  ('Foose Bar', 'Foose Bar', NULL),
  ('Foo Sebar', 'Foo Sebar', NULL),
  ('Foosebar', 'Foosebar', NULL),
  ('Foo Barse', 'Foo Barse', NULL),
  /* \s+spa$ */
  ('foobar spa', 'foobar$spa', NULL),
  ('Foobar Spa', 'Foobar$spa', NULL),
  ('Foo Spa Bar', 'Foo Spa Bar', NULL),
  ('Foospa Bar', 'Foospa Bar', NULL),
  ('Foo Spabar', 'Foo Spabar', NULL),
  ('Foospabar', 'Foospabar', NULL),
  ('Foo Barspa', 'Foo Barspa', NULL),
  /* \s+srl$ */
  ('foobar srl', 'foobar$srl', NULL),
  ('Foobar Srl', 'Foobar$srl', NULL),
  ('Foo Srl Bar', 'Foo Srl Bar', NULL),
  ('Foosrl Bar', 'Foosrl Bar', NULL),
  ('Foo Srlbar', 'Foo Srlbar', NULL),
  ('Foosrlbar', 'Foosrlbar', NULL),
  ('Foo Barsrl', 'Foo Barsrl', NULL),
  /* test non-simplified characters */
  ('Jyväskylä', 'Jyväskylä', 'unicode characters not affected'),
  ('Ä änd B', 'Ä änd B', 'unicode characters not affected'),
  ('Ä and B', 'Ä & B', 'unicode characters not affected'),
  /* common interaction terms */
  ('Foobar And Company', 'Foobar &$co', NULL),
  ('Foobar & Company', 'Foobar &$co', NULL),
  ('Foobar And Co', 'Foobar &$co', NULL),
  ('Foobar & Co', 'Foobar &$co', NULL),
  /* empty string */
  ('', '', 'Empty string')
;

  SELECT plan(count(*)::INT + 23) FROM name_abbreviation_tests;

  SELECT is(
    etl.replace_name_abbreviations(test_string),
    expected,
    COALESCE(quote_literal(description) || ': ', '') ||
      quote_literal(test_string) || ' -> ' ||
      quote_literal(expected)
  ) FROM name_abbreviation_tests;

  SELECT is(
    etl.replace_name_abbreviations(
      'Foobar Company',
      5
    ),
    'Foobar$co',
    'test passing recursion arguments by POSITION'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foobar Company',
      max_recursion := 5
    ),
    'Foobar$co',
    'test passing recursion arguments by name'
  );

  /* recursion | string IN  | string OUT */
  /* 0         | Foo co Bar | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo co Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x0 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo co Bar',
      max_recursion := 0
    ),
    'Foo co Bar',
    'test recursion x0'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo co Bar'',
      max_recursion := -1
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x0'
  );

  /* recursion | string IN       | string OUT */
  /* 0         | Foo company Bar | Foo co Bar */
  /* 1         | Foo co Bar      | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo company Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x1 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo company Bar',
      max_recursion := 1
    ),
    'Foo co Bar',
    'test recursion x1'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo company Bar'',
      max_recursion := 0
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x0'
  );

  /* recursion | string IN            | string OUT */
  /* 0         | Foo companympany Bar | Foo company Bar */
  /* 1         | Foo company Bar      | Foo co Bar */
  /* 2         | Foo co Bar           | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympany Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x2 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympany Bar',
      max_recursion := 2
    ),
    'Foo co Bar',
    'test recursion x2'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympany Bar'',
      max_recursion := 1
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x2'
  );

  /* recursion | string IN                 | string OUT */
  /* 0         | Foo companympanympany Bar | Foo companympany Bar */
  /* 1         | Foo companympany Bar      | Foo company Bar */
  /* 2         | Foo company Bar           | Foo co Bar */
  /* 3         | Foo co Bar                | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympany Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x3 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympany Bar',
      max_recursion := 3
    ),
    'Foo co Bar',
    'test recursion x3'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympanympany Bar'',
      max_recursion := 2
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x3'
  );

  /* recursion | string IN                      | string OUT */
  /* 0         | Foo companympanympanympany Bar | Foo companympanympany Bar */
  /* 1         | Foo companympanympany Bar      | Foo companympany Bar */
  /* 2         | Foo companympany Bar           | Foo company Bar */
  /* 3         | Foo company Bar                | Foo co Bar */
  /* 4         | Foo co Bar                     | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympanympany Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x4 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympanympany Bar',
      max_recursion := 4
    ),
    'Foo co Bar',
    'test recursion x4'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympanympanympany Bar'',
      max_recursion := 3
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x4'
  );

  /* recursion | string IN                           | string OUT */
  /* 0         | Foo companympanympanympanympany Bar | Foo companympanympanympany Bar */
  /* 1         | Foo companympanympanympany Bar      | Foo companympanympany Bar */
  /* 2         | Foo companympanympany Bar           | Foo companympany Bar */
  /* 3         | Foo companympany Bar                | Foo company Bar */
  /* 4         | Foo company Bar                     | Foo co Bar */
  /* 5         | Foo co Bar                          | Foo co Bar */
  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympanympanympany Bar'
      -- max_recursion default 5
    ),
    'Foo co Bar',
    'test recursion x5 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympanympanympany Bar',
      max_recursion := 5
    ),
    'Foo co Bar',
    'test recursion x5'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympanympanympanympany Bar'',
      max_recursion := 4
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x5'
  );

  /* recursion | string IN                                | string OUT */
  /* 0         | Foo companympanympanympanympanympany Bar | Foo companympanympanympanympany Bar */
  /* 1         | Foo companympanympanympanympany Bar      | Foo companympanympanympany Bar */
  /* 2         | Foo companympanympanympany Bar           | Foo companympanympany Bar */
  /* 3         | Foo companympanympany Bar                | Foo companympany Bar */
  /* 4         | Foo companympany Bar                     | Foo company Bar */
  /* 5         | Foo company Bar                          | Foo co Bar */
  /* 6         | Foo co Bar                               | Foo co Bar */
  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympanympanympanympanympany Bar'',
      max_recursion := 5
    )',
    'Name replacement recursion exceeded',
    'test recursion x6 - Default'
  );

  SELECT is(
    etl.replace_name_abbreviations(
      string := 'Foo companympanympanympanympanympany Bar',
      max_recursion := 6
    ),
    'Foo co Bar',
    'test recursion x6'
  );

  SELECT throws_ok(
    'SELECT etl.replace_name_abbreviations(
      string := ''Foo companympanympanympanympanympany Bar'',
      max_recursion := 5
    )',
    'Name replacement recursion exceeded',
    'Test that limiting number OF recursion works - x6'
  );

ROLLBACK;
