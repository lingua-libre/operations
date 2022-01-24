#!/bin/bash

### Sparql query.
query="?record prop:P2 entity:Q2 ;
          prop:P3 ?file ;
          prop:P5 ?locutor ;
          prop:P7 ?transcription ;
          prop:P6 ?date ;
          prop:P4 ?lang.
  ?locutor prop:P11 ?user.

  OPTIONAL{ ?lang prop:P13 ?langIso. }
  OPTIONAL { ?record prop:P18 ?qualif. }

  ?locutor rdfs:label ?locutorLabel.
  ?lang rdfs:label ?langLabel FILTER (lang(?langLabel) = 'en').

  BIND( CONCAT(
    SUBSTR(STR(?lang), 31),
    '-',
    IF(BOUND(?langIso), ?langIso, 'mis'),
    IF(BOUND(?langLabel), CONCAT('-', ?langLabel), '')
  ) AS ?langstr)
  BIND( IF( STR(?locutorLabel) = ?user, '', CONCAT( ' (', ?locutorLabel, ')' ) ) AS ?locutorstr )
  BIND( IF(BOUND(?qualif), CONCAT(' (', ?qualif, ')'), '') AS ?qualifstr )
  BIND(CONCAT(?langstr, '/', ?user, ?locutorstr, '/', ?transcription, ?qualifstr, '.wav') AS ?filename)
"
queryFilterRecent="FILTER( ?date > \"`date --rfc-3339=date --date=\"- 5 days\"`\"^^xsd:dateTime )."

# Create (if it doesn't exist already) a temp folder for all the records we will download
mkdir -p  /tmp/datasets /tmp/datasets/raw/

# Download all recently (> 2 days) recorded files
# We --forcedownload  the recently uploaded files only,
# to get the newer version of those that have been updated since last run
echo "--> Force the download of recent changes..."
/usr/bin/python3.8 /home/www/CommonsDownloadTool/commons_download_tool.py --keep --sparqlurl https://lingualibre.org/bigdata/namespace/wdq/sparql --sparql "SELECT ?file ?filename WHERE { ${query} ${queryFilterRecent} }" --threads 4 --directory  /tmp/datasets/raw/ --forcedownload --nozip --fileformat ogg

# Check that we have all the files (or download them) and zip everything
# We could use zip directly (as the previous command also ensure we got every new files),
# but by doing it this way deleted files on Lingua Libre won't be shipped even if cached.
echo "--> [CANCELLED/PAUSED:] Download and package ALL sounds..."
#     /usr/bin/python3.8 /home/www/CommonsDownloadTool/commons_download_tool.py --keep --sparqlurl https://lingualibre.org/bigdata/namespace/wdq/sparql --sparql "SELECT ?file ?filename WHERE { ${query} }" --threads 4 --directory  /tmp/datasets/raw/ --output "/tmp/datasets/lingualibre_full.zip" --fileformat ogg

# Download and package each language individually
echo "--> Download and package each language individually"
bashArray=("Q101-srr-Serer" "Q254-krc-Karachay-Balkar" "Q304-mya-Burmese" "Q32-isl-Icelandic" "Q36-swa-Swahili" "Q55890-vls-West Flemish" "Q395932-bse-Wushi" "Q430329-mis-Gutnish" "Q733156-mis-meridional Cilentan" "Q195-gsw-Alemannic German" "Q683869-mni-Meitei language" "Q386444-ckb-Sorani" "Q683869-mni-Meitei language" "Q300-dan-Danish" "Q313-tat-Tatar" "Q384-lat-Latin" "Q5049-wls-Wallisian" "Q74905-mis-Sursilvan" "Q51302-tay-Atayal" "Q51306-pwn-Paiwan" "Q386441-duf-Ndrumbea" "Q305-ind-Indonesian" "Q193-hau-Hausa" "Q437-mal-Malayalam" "Q216-min-Minangkabau" "Q392-ces-Czech" "Q531093-tpw-Old Tupi" "Q655434-sxu-Upper Saxon German" "Q165-hat-Haitian Creole" "Q389-jpn-Japanese" "Q177-grc-Ancient Greek" "Q181-lin-Lingala" "Q51236-pcd-Picard" "Q52296-rcf-Réunion Creole" "Q205-gre-Greek" "Q231-myv-Erzya" "Q273-kab-Kabyle" "Q536602-sba-Ngambay" "Q52206-ybb-Yemba" "Q204947-tui-Tupuri" "Q169-tgl-Tagalog" "Q388-que-Quechua" "Q345-lua-Luba-Kasai language" "Q45-nor-Norwegian" "Q259-scn-Sicilian" "Q204943-mcn-Massa language" "Q140-glg-Galician" "Q229-rup-Aromanian" "Q204946-mua-Mundang" "Q424673-shi-Shilha" "Q131-hye-Armenian" "Q40979-guc-Wayuu" "Q555966-mnw-Mon" "Q1187-mis-Lemosin dialect" "Q318-bam-Bambara" "Q258-nso-Northern Sotho" "Q459005-cak-Kaqchikel" "Q43042-shu-Chadian Arabic" "Q84029-mis-Martinique Creole" "Q338540-mis-Toki Pona" "Q329-kik-Gikuyu" "Q207-kor-Korean" "Q159-dyu-Dioula language" "Q52072-mhk-Nga'ka language" "Q46-ltz-Luxembourgish" "Q52071-dua-Duala" "Q720542-mis-Salentino" "Q125-guj-Gujarati" "Q127-tam-Tamil" "Q52073-bdu-Oroko" "Q52074-bzm-Londo" "Q405-bas-Basaa language" "Q52068-bum-Bulu language" "Q133-slv-Slovene" "Q19858-bci-Baoulé" "Q221-cor-Cornish" "Q733159-mis-centro-meridional Calabrian" "Q170137-mos-Mossi" "Q4465-mis-Teochew dialect" "Q130-zho-Chinese writing" "Q52067-bbj-Ghomala' language" "Q123270-mis-British English" "Q321-gaa-Ga" "Q51299-hav-Havu" "Q136-tha-Thai" "Q154-amh-Amharic" "Q225-ace-Acehnese" "Q6714-arq-Algerian Arabic" "Q78-jav-Javanese" "Q713359-----Nanjing Dialect" "Q425-kok-Konkani" "Q242-fon-Fon" "Q39-tel-Telugu" "Q123-hin-Hindi" "Q429-bik-Bikol languages" "Q83641-gcf-Guadeloupean Creole French" "Q397-heb-Hebrew" "Q52295-atj-Atikamekw" "Q161-ban-Balinese" "Q297-tur-Turkish" "Q339-sat-Santali" "Q206-gle-Irish" "Q80-kan-Kannada" "Q182-kur-Kurdish" "Q251-ibo-Igbo" "Q99628-fsl-French Sign Language" "Q390278-kmr-Kurmanji" "Q209-bre-Breton" "Q204940-ken-Nyang language" "Q322719-mis-Baleswari Oriya" "Q113-cmn-Mandarin Chinese" "Q141-cym-Welsh" "Q48-fas-Persian" "Q38-mlg-Malagasy" "Q33-fin-Finnish" "Q208-vie-Vietnamese" "Q264201-ary-Moroccan Arabic" "Q646153-ajp-South Levantine Arabic" "Q35-nld-Dutch" "Q115107-bcl-Central Bikol" "Q4901-shy-Shawiya language" "Q306-mkd-Macedonian" "Q203-cat-Catalan" "Q150-afr-Afrikaans" "Q299-eus-Basque" "Q385-ita-Italian" "Q446-pan-Punjabi" "Q138-aze-Azerbaijani" "Q930-gsc-Gascon dialect" "Q126-por-Portuguese" "Q931-lnc-Languedocien dialect" "Q219-ara-Arabic" "Q221062-yue-Cantonese" "Q44-swe-Swedish" "Q129-rus-Russian" "Q386-spa-Spanish" "Q311-oci-Occitan" "Q34-mar-Marathi" "Q24-deu-German" "Q43-ukr-Ukrainian" "Q37-ron-Romanian" "Q22-eng-English" "Q25-epo-Esperanto" "Q336-ori-Odia" "Q307-ben-Bengali" "Q298-pol-Polish" "Q21-fra-French")

for qidpath in ${bashArray[@]};
# for qidpath in /tmp/datasets/raw/*;
do
  qid=$(echo ${qidpath##*/} | cut -d'-' -f 1)
  if [[ $qid == Q* ]] ; then
    echo "--> Processing ${qid}..."
    /usr/bin/python3.8 /home/www/CommonsDownloadTool/commons_download_tool.py --keep --sparqlurl https://lingualibre.org/bigdata/namespace/wdq/sparql --sparql "SELECT ?file ?filename WHERE { ${query} ?record prop:P4 entity:${qid}. }" --threads 4 --directory  /tmp/datasets/raw/ --output "/tmp/datasets/${qidpath##*/}.zip" --fileformat ogg
  fi
done

### MOVE TO PUBLIC FOLDER
echo "--> Move all zip archives in the public datasets folder"
mv /tmp/datasets/*.zip /home/www/datasets/
