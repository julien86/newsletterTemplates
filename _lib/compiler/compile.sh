echo "Hi, $USER!"

#compile less file
echo "compiling style.less ..."
lessc ${PWD}/theme/less/style.less ${PWD}/theme/css/style.css
lessc ${PWD}/theme/less/newsletter.less ${PWD}/theme/css/newsletter.css

#inline style in html
echo "inlining newsletter.html ..."
#doc premailer: http://rubydoc.info/gems/premailer/1.8.2/Premailer
# https://github.com/premailer/premailer/wiki/Premailer-Command-Line-Usage
# UTILISER IMPÉRATIVEMENT AVEC LE PARSER NOKOGIRI
templateName=$(basename "$PWD")
domain=http://newsletter-templates.expert-infos.com
baseurl=$domain/templates/$templateName/
premailer --base-url=$baseurl --css=${PWD}/theme/css/style.css --entities --verbose ${PWD}/newsletter.html > ${PWD}/newsletter-inline.html

#Désactivation des commentaires sur les balises Posta Nova
echo "enabling PostaNova tags ..."
cp newsletter-inline.html newsletter-inline-postanova.html

#Suppression des échappements HTML et CSS
perl -pi -e 's/<!--{{//g;' newsletter-inline-postanova.html
perl -pi -e 's/}}-->//g;' newsletter-inline-postanova.html
perl -pi -e 's/\/\*{{//g;' newsletter-inline-postanova.html
perl -pi -e 's/}}\*\///g;' newsletter-inline-postanova.html

#Remplacement des balises d'ouverture/fermeture en ASP
perl -pi -e 's/%%{{/<%/g;' newsletter-inline-postanova.html
perl -pi -e 's/}}%%/%>/g;' newsletter-inline-postanova.html
#Gestion des appels de variables via Dictionary
perl -pi -e 's/##\(\(/<%=colorParsing\.Item\("/g;' newsletter-inline-postanova.html
perl -pi -e 's/\)\)##/"\)%>/g;' newsletter-inline-postanova.html

#Remplacement des balises d'ouverture/fermeture de Posta Nova
perl -pi -e 's/##{{/<?/g;' newsletter-inline-postanova.html
perl -pi -e 's/}}##/?>/g;' newsletter-inline-postanova.html

#Remplacement des attributs spécifiques Premailer
perl -pi -e 's/-premailer-background/background/g;' newsletter-inline-postanova.html
perl -pi -e 's/-premailer-cellpadding(.*?); //g;' newsletter-inline-postanova.html
perl -pi -e 's/-premailer-cellspacing(.*?); //g;' newsletter-inline-postanova.html
perl -pi -e 's/-premailer-width(.*?); //g;' newsletter-inline-postanova.html
perl -pi -e 's/-premailer-height(.*?); //g;' newsletter-inline-postanova.html
perl -pi -e 's/( ?)-premailer-hidden( ?)//g;' newsletter-inline-postanova.html

#Suppression des balises de récupération des styles
perl -pi -e 's/<(.+?)data-type="getstyle" (.*?)style=/style=/g;' newsletter-inline-postanova.html
perl -pi -e 's/\/><!--getstyle-->//g;' newsletter-inline-postanova.html
perl -pi -e 's/><!--getstyle--><\/(.+?)>//g;' newsletter-inline-postanova.html

#Suppression des balises de récupération des hrefs
perl -pi -e 's/<(.+?)data-type="gethref" (.*?)href="//g;' newsletter-inline-postanova.html
perl -pi -e 's/" (.+?)><!--gethref--><\/(.+?)>//g;' newsletter-inline-postanova.html

#Remplacement des attributs PostaNova
perl -pi -e 's/lien_message_online="lien_message_online"/lien_message_online/g;' newsletter-inline-postanova.html
perl -pi -e 's/lien_print="lien_print"/lien_print/g;' newsletter-inline-postanova.html
perl -pi -e 's/lien_blackliste="lien_blackliste"/lien_blackliste/g;' newsletter-inline-postanova.html
perl -pi -e 's/lien_mailto="lien_mailto"/lien_mailto/g;' newsletter-inline-postanova.html

#Suppression des éléments à supprimer
perl -pi -e 's/<!--DEL\{\{-->.+?<!--\}\}DEL-->//g;' newsletter-inline-postanova.html
perl -pi -e 's/\/\*DEL\{\{\*\/.+?\/\*\}\}DEL\*\///g;' newsletter-inline-postanova.html
#test pour multiline, à débugguer
#<!--DEL\{\{-->\n(?s).+?\n<!--\}\}DEL-->

echo "That's all folks !"