create temp table foo (x text);
insert into foo values
('(inactive)'),
(' and '),
(' och '),
(' en '),
(' und '),
('%development%'),
('%develop%'),
('%development%'),
('%develop%'),
('%group%'),
('%designated activity company%'),
('%limited partnership%'),
('%generation%'),
('%investment%'),
('%limited%'),
('%company%'),
('%public ltd co%'),
('%corporation%'),
('%ltd liability co%'),
('%AktG%'),
('%Aktiengesellschaft%'),
('%incorporated%'),
('%holdings%'),
('%holding%'),
('%international%'),
('%government%'),
('%berhad%'),
('%resources%'),
('%resource%'),
('%shipping%'),
('%partners%'),
('%partner%'),
('%associates%'),
('%associate%'),
('%group%'),
('% dac'),
('% sas'),
('% asa'),
('% spa'),
('% pte'),
('% srl'),
('% ltd'),
('% plc'),
('% pcl'),
('% bsc'),
('% sarl'),
('% as'),
('% nv'),
('% bv'),
('% cv'),
('% pt'),
('% sa'),
('% se'),
('% lp'),
('% corp'),
('% co'),
('% llc'),
('% ag'),
('% inc'),
('% hldgs'),
('% intl'),
('% govt'),
('% bhd'),
('% lt'),
('%generation%'),
('%investment%'),
('%financial%');

select * from (
	select foo.x, company_name, simplified_name, row_number() over (partition by foo.x) as z from foo
	inner join company on lower(company_name) like foo.x
) z
where  z.z <= 3

/* % ag	Sbb Ag	sbb ag	1 */
/* % ag	Sulzer Ag	sulzer ag	2 */
/* % ag	Axeon Ag	axeon ag	3 */
/* % as	Sari Kanat Enerji Ve San Tic As	sarikanatenerjivesantic as	1 */
/* % as	Geen Holding As	geenhldgs as	2 */
/* % as	Aquapalace As	aquapalace as	3 */
/* % asa	Element Asa	element asa	1 */
/* % asa	Plugging Specialists International Asa	pluggingspecialistsintl asa	2 */
/* % asa	Awilco Lng Asa	awilcolng asa	3 */
/* %associate%	Us Security Associates Holding	ussecurityassoc hldgs	1 */
/* %associate%	S. G. Pinney & Associates, Inc.	sgpinney&assoc inc	2 */
/* %associate%	Alister Associates, Llc	alisterassoc llc	3 */
/* %associates%	Us Security Associates Holdings Inc	ussecurityassochldgs inc	1 */
/* %associates%	Tl Roof & Associates Construct	tlroof&assocconstruct	2 */
/* %associates%	Turley Associates Inc	turleyassoc inc	3 */
/* %berhad%	Kumpulan Melaka Berhad	kumpulanmelaka bhd	1 */
/* %berhad%	Octagon Consolidated Berhad	octagonconsolidated bhd	2 */
/* %berhad%	Cagamas Mbs Berhad	cagamasmbs bhd	3 */
/* % bhd	Malaysia Lng Sdn Bhd	malaysialngsdn bhd	1 */
/* % bhd	Airasia Bhd	airasia bhd	2 */
/* % bhd	Oilfab Sdn Bhd	oilfabsdn bhd	3 */
/* % bsc	Gulf International Bank Bsc	gulfintlbank bsc	1 */
/* % bsc	The Bahrain Petroleum Company Bsc	thebahrainpetroleumco bsc	2 */
/* % bsc	Fujitsu Bsc	fujitsu bsc	3 */
/* % bv	Eldim Bv	eldim bv	1 */
/* % bv	Solarfields Nederland Bv	solarfieldsnederland bv	2 */
/* % bv	Mc Oil & Gas Sumatra Bv	mcoil&gassumatra bv	3 */
/* % co	Five Ocean Maritime Serv Co	fiveoceanmaritimeserv co	1 */
/* % co	Russian Oil Co	russianoil co	2 */
/* % co	Five Stars Fujian Shipping Co	fivestarsfujianshp co	3 */
/* %company%	R.P. Valois & Company, Inc.	rpvalois&co inc	1 */
/* %company%	Durham Electric Company	durhamelectric co	2 */
/* %company%	Enerfin Energy Company Of Canada, Inc.	enerfinenergycoofcanada inc	3 */
/* % corp	E&R Engineering Corp	e&rengineering corp	1 */
/* % corp	Asahipen Corp	asahipen corp	2 */
/* % corp	Consolidated Fabricators Corp	consolidatedfabricators corp	3 */
/* %corporation%	Qualitrol Corporation	qualitrol corp	1 */
/* %corporation%	Kaydon Custom Filtration Corporation	kaydoncustomfiltration corp	2 */
/* %corporation%	East China Electric Power Group Corporation	eastchinaelectricpowergrp corp	3 */
/* % cv	Global Offshore Mexico S De Rl De Cv	globaloffshoremexicosderlde cv	1 */
/* % cv	Industrias Derivadas Del Etileno Sa De Cv	industriasderivadasdeletilenosade cv	2 */
/* % cv	Compania Agroelectrica De Yucatan Sde Rl De Cv	companiaagroelectricadeyucatansderlde cv	3 */
/* % dac	Appletree Securities Dac	appletreesecurities dac	1 */
/* % dac	Endo Dac	endo dac	2 */
/* % dac	Constellation Aircraft Leasing Dac	constellationaircraftleasing dac	3 */
/* %develop%	Jiangsu Changjiangkou Development Group Co Ltd	jiangsuchangjiangkoudevgrpco ltd	1 */
/* %develop%	Six Nations Development Corporation	sixnationsdev corp	2 */
/* %develop%	Qinghai Jinrui Mineral Develop	qinghaijinruimineraldev	3 */
/* %development%	Acfd Development Llc	acfddev llc	1 */
/* %development%	Quanjiao Urban Infrastructure Development And Construction Co Ltd	quanjiaourbaninfrastructuredev&constructionco ltd	2 */
/* %development%	Girkin Development Llc	girkindev llc	3 */
/* %financial%	Tisco Financial Group Pcl	tiscofingrp pcl	1 */
/* %financial%	C&F Financial Corp	c&ffin corp	2 */
/* %financial%	Velocity Financial Group	velocityfingrp	3 */
/* %generation%	Salinas River Cogeneration Company	salinasrivercogen co	1 */
/* %generation%	Inner Mongolia Shangdu Power Generation Co Ltd	innermongoliashangdupowergenco ltd	2 */
/* %generation%	Inner Mongolia Shangdu Power Generation Co Ltd	innermongoliashangdupowergenco ltd	3 */
/* %government%	Government Of Belarus	govtofbelarus	1 */
/* %government%	Government Of Mali	govtofmali	2 */
/* %government%	Government Of Morocco	govtofmorocco	3 */
/* % govt	China Govt	china govt	1 */
/* % govt	Dalian Muni Govt	dalianmuni govt	2 */
/* % govt	United States Govt	unitedstates govt	3 */
/* %group%	Royal Dutch/Shell Group Of Cos	royaldutchshellgrpofcos	1 */
/* %group%	Brunswick Group Llp	brunswickgrpllp	2 */
/* %group%	Lambo Group Bhd	lambogrp bhd	3 */
/* % hldgs	Fairfax Financial Hldgs	fairfaxfin hldgs	1 */
/* % hldgs	Sc Assets Hldgs	scassets hldgs	2 */
/* % hldgs	Fullsun Intl Hldgs	fullsunintl hldgs	3 */
/* %holding%	Letterone Holdings Sa	letteronehldgs sa	1 */
/* %holding%	Gedik Yatirim Holding As	gedikyatirimhldgs as	2 */
/* %holding%	Ooh Holdings Ltd	oohhldgs ltd	3 */
/* %holdings%	Camac Energy Holdings Ltd	camacenergyhldgs ltd	1 */
/* %holdings%	Host Spain Holdings Sl	hostspainhldgssl	2 */
/* %holdings%	Nation Safe Drivers Holdings Llc	nationsafedrivershldgs llc	3 */
/* % inc	First Corporate Sedans Inc	firstcorporatesedans inc	1 */
/* % inc	All Solar Inc	allsolar inc	2 */
/* % inc	Barber Oil Inc	barberoil inc	3 */
/* %incorporated%	Jiangsu Yanxin Science & Technology Incorporated Corp	jiangsuyanxinscience&technologyinc corp	1 */
/* %incorporated%	Biliran Geothermal Incorporated	bilirangeothermal inc	2 */
/* %incorporated%	Solforce Systems Incorporated	solforcesystems inc	3 */
/* %international%	Petrochina International (Kazakhstan) Co Ltd	petrochinaintlkazakhstanco ltd	1 */
/* %international%	China International Engineering Consulting Corporation	chinaintlengineeringconsulting corp	2 */
/* %international%	Transera International Logistics Ltd	transeraintllogistics ltd	3 */
/* % intl	Hongkong Fuhua Marine Intl	hongkongfuhuamarine intl	1 */
/* % intl	Electrical Components Intl	electricalcomponents intl	2 */
/* % intl	Renewable Power Intl	renewablepower intl	3 */
/* %investment%	Gas Oil Investments	gasoilinvests	1 */
/* %investment%	Zhuji Xincheng Investment Development Group Co Ltd	zhujixinchenginvestdevgrpco ltd	2 */
/* %investment%	Novacap Investments Inc	novacapinvests inc	3 */
/* %limited%	Ratchaburi World Cogeneration Company Limited	ratchaburiworldcogenco ltd	1 */
/* %limited%	Sapucaia Leasing Limited	sapucaialeasing ltd	2 */
/* %limited%	Lmz Energy (India) Limited	lmzenergyindia ltd	3 */
/* %limited partnership%	Indeck-Oswego Limited Partnership	indeckoswego lp	1 */
/* %limited partnership%	Heritage Royalty Limited Partnership	heritageroyalty lp	2 */
/* %limited partnership%	Indeck-Olean Limited Partnership	indeckolean lp	3 */
/* % llc	Power County Wind Parks Llc	powercountywindparks llc	1 */
/* % llc	Ranger Solar Llc	rangersolar llc	2 */
/* % llc	Bluestone Energy Services Llc	bluestoneenergyservices llc	3 */
/* % lp	Byron Park Lp	byronpark lp	1 */
/* % lp	Incline B Aviation Lp	inclinebaviation lp	2 */
/* % lp	Ggp Operating Partnership Lp	ggpoperatingprthip lp	3 */
/* % lt	Skypak Services Specialties Lt	skypakservicesspecialties ltd	1 */
/* % lt	Henan Yicheng New Energy Co Lt	henanyichengnewenergyco ltd	2 */
/* % lt	Bmc Software Finance Cayman Lt	bmcsoftwarefinancecayman ltd	3 */
/* % ltd	Svatantra Microfin Pvt Ltd	svatantramicrofinpvt ltd	1 */
/* % ltd	Tvs Investments Ltd	tvsinvests ltd	2 */
/* % ltd	Amba River Coke Ltd	ambarivercoke ltd	3 */
/* %ltd liability co%	Kailuan Group Ltd Liability Co	kailuangrp llc	1 */
/* %ltd liability co%	Stroygazconsulting Ltd Liability Co	stroygazconsulting llc	2 */
/* %ltd liability co%	Mckittrick Ltd Liability Co	mckittrick llc	3 */
/* % nv	Svex Nv	svex nv	1 */
/* % nv	Aviapartner Nv	aviaprt nv	2 */
/* % nv	Van Moer Transport Nv	vanmoertransport nv	3 */
/* %partner%	Thomasson Partner Associates Inc	thomassonprtassoc inc	1 */
/* %partner%	Harren & Partner Ship Mgmt-Geu	harren&prtshipmgmtgeu	2 */
/* %partner%	Blackstone Real Estate Partners Vii Lp	blackstonerealestateprtvii lp	3 */
/* %partners%	Dunlap And Partners Engineers	dunlap&prtengineers	1 */
/* %partners%	Atrium Partners A/S	atriumprtas	2 */
/* %partners%	Ove Arup & Partners Ireland	ovearup&prtireland	3 */
/* % pcl	Demco Pcl	demco pcl	1 */
/* % pcl	Syn Mun Kong Insurance Pcl	synmunkonginsurance pcl	2 */
/* % pcl	Vintcom Technology Pcl	vintcomtechnology pcl	3 */
/* % plc	Investrust Bank Plc	investrustbank plc	1 */
/* % plc	Reckitt Benckiser Treasury Services Plc	reckittbenckisertreasuryservices plc	2 */
/* % plc	Helios Underwriting Plc	heliosunderwriting plc	3 */
/* % pt	Jasamarga Surabaya Mojokerto Pt	jasamargasurabayamojokerto pt	1 */
/* % pt	Intercipta Sempana Pt	interciptasempana pt	2 */
/* % pt	Trakindo Utama Pt	trakindoutama pt	3 */
/* % pte	Indika Energy Cap Ii Pte	indikaenergycapii pte	1 */
/* % pte	Perita Shipping & Trading Pte	peritashp&trading pte	2 */
/* % pte	New Yangtze Navigation Sng Pte	newyangtzenavigationsng pte	3 */
/* %public ltd co%	Opus Global Public Ltd Co	opusglobal plc	1 */
/* %public ltd co%	Opus Global Public Ltd Co	opusglobal plc	2 */
/* %resource%	Realm Resources Ltd	realmres ltd	1 */
/* %resource%	China Resources Power Hunan Co., Ltd.	chinarespowerhunanco ltd	2 */
/* %resource%	Zinccorp Resources Inc	zinccorpres inc	3 */
/* %resources%	Castle Resources Inc	castleres inc	1 */
/* %resources%	Mzi Resources Ltd	mzires ltd	2 */
/* %resources%	Dl Resources Llc	dlres llc	3 */
/* % sa	Procesadora De Oleaginosas Prolega Sa	procesadoradeoleaginosasprolega sa	1 */
/* % sa	Uabl Paraguay Sa	uablparaguay sa	2 */
/* % sa	Geodis Sa	geodis sa	3 */
/* % sarl	Aldgate Tower Sarl	aldgatetower sarl	1 */
/* % sarl	Kias Airlines Sarl	kiasairlines sarl	2 */
/* % sarl	Slb Sarl	slb sarl	3 */
/* % sas	Parholding Sas	parhldgs sas	1 */
/* % sas	Valbio Sas	valbio sas	2 */
/* % sas	Optimum Tracker Sas	optimumtracker sas	3 */
/* % se	Yuliana Fong Se	yulianafong se	1 */
/* % se	Dekra Se	dekra se	2 */
/* % se	Wepa Industrieholding Se	wepaindustriehldgs se	3 */
/* %shipping%	Fortune Star Shipping	fortunestarshp	1 */
/* %shipping%	Western Bulk Shipping As	westernbulkshp as	2 */
/* %shipping%	Rogers Nor Shipping Inc	rogersnorshp inc	3 */
/* % spa	Rea Dalmine Spa	readalmine spa	1 */
/* % spa	Ccpl Inerti Spa	ccplinerti spa	2 */
/* % spa	Sisal Group Spa	sisalgrp spa	3 */
/* % srl	Grup M Agency Srl	grupmagency srl	1 */
/* % srl	Viscolube Srl	viscolube srl	2 */
/* % srl	Caroli Foods Group Srl	carolifoodsgrp srl	3 */
