# Frit's Encrypt
## _Let's Encrypt_ und FRITZ!Box Remotezugang
Ein kleiner Hindernis-Parcours und wie man ihn meistert.

## Ist doch (k)ein Problem
Möchte man seine FRITZ!Box aus der Ferne erreichen können, so ist das prinzipiell nach erfolgter Freischaltung ohne Weiteres möglich. Man kann einfach per Browser auf die HTTPS-Oberfläche der FRITZ!Box zugreifen, sobald man die entsprechenden Einstellungen in der FRITZ!Box vorgenommen hat.<br> Für den verschlüsseltten HTTPS-Verkehr, benötigt die FRITZ!Box ein SSL-Zertifikat. Das auf der FRITZ!Box vorhandene Zertifikat ist jedoch von keiner offiziellen Zertifizierungsstelle signiert, weshalb zu Recht alle Browser mehr oder weniger ebenso ein- wie aufdringlich darauf hinweisen, dass die Verbindung   **nicht sicher** ist. Wen das nicht stört, der kann hier aufhören zu lesen. <br>
Hat man allerdings den Ehrgeiz, es "richtig" zu machen, benötigt man ein offizielles Zertifikat.
Das setzt voraus, dass der Server über einen im Internet-DNS eingetragenen Namen verfügt, was wiederum voraussetzt, dass man über eine eigene Domain verfügt. Diesen Aufwand wird man sicher nur in Ausnahmefällen nur wegen einer FRITZ!Box auf sich nehmen. Aber hat man schon eine eigene Domain, dann bietet es sich an, diese zum Zugriff auf die FRITZ!Box nutzen.

So lange die FRITZ!Box nicht im DNS verzeichnet ist, kann man sie nur erreichen, wenn man ihre IP-Adresse kennt.
**Nur:** Beim durchschnittlichen Heimnetz ändert sich diese jedoch bei jeder Einwahl, auch bei  Zwangstrennung durch den Provider (z. B. täglich).

Zur Lösung derartiger Probleme, wurde DynDNS erfunden, ein Framework zur Bereitstellung kurzlebiger DNS-Einträge, die sich schnell ändern lassen. Und alle namhaften Provider unterstützen für die bei Ihnen gehosteten Domains DynDNS.

Und, wie man es von einer FRITZ!Box erwartet, unterstützt diese natürlich auch DynDNS, so
dass sie Ihre jeweilige Adresse bei jeder Verbindung im DNS eintragen kann, man muss es nur konfigurieren. 

Bis hierher ist auch alles ohne Probleme machbar,
aber die Erlangung eines offiziellen, kostenfreien Zertifikats von Let's Encrypt erfordert einen gewissen Aufwand und ein paar Ideen. Denn _Let's Encrypt_ Zertifikate haben eine kurze Laufzeit und müssen regelmaßig, sinnvollerweise automatisiert, erneuert werden.

## Zertifikat von _Let's Encrypt_
Zertifikate von _Let's Encrypt_ verwendet man normalerweise für eigene Webserver mit eigenem DNS-Namen. Betreibt man einen solchen, so betreibt man ihn (hoffentlich) nur mit HTTPS, nicht mit dem unverschlüsselten HTTP. Höchstens um fehlgeleite Nutzer wieder auf den rechten (verschlüsselten) Weg zu bringen (per Redirect zu HTTPS) ist ein HTTP-Zugang sinnvoll. Und dann gibt es da noch einen legitimen Fall, bei dem unverschlüsseltes HTTP vonnöten ist. <br>
Und zwar bei der Erlangung eines _Let's Encrypt_ Zertifikats.
Das Challenge-Response Verfahren mit dessen Hilfe man beweist, dass man tatsächlich die Kontrolle über die angefragte Domain hat, erfordert es, dass man (temporär) eine eigens pro Domain für diesen Zweck erzeugte Datei unter einem bestimmten Pfad per HTTP (ohne S) zum Download bereitstellt.

Dieses automatisierte Verfahren zur Erlangung eines Zertifikats ist übrigens unter der Abkürzung **ACME** (**A**utomatic **C**ertificate **M**anagement **E**nvironment),  außer in der Dokumentation (RFC 8555) auch in Wikipedia beschrieben. Ausser _Let's Encrypt_ verwenden auch andere ACME (z B. ZeroSSL, Google Cloud).

## Wir brauchen also einen Webserver
Wegen des ACME-Verfahrens, ist also ein Webserver erforderlich, auf den man dynamisch die Challenges (in ein bestimmtes Verzeichnis) kopieren kann. Das muss kein schwergewichtiger Webserver wie Apache oder nginx sein, ein Python-1-4 Zeiler (für IPv6 mindestens Python  3.8) tut es auch. Der Server muss nur in der Lage sein, Dateien unter `http://<DNS-name>/.well-known/acme-challenge/` auszuliefern.
Eine genauere Anleitung zum Aufsetzen des Servers würde den Umfang dieses Beitrags sprengen, aber eine Internet-Recherche liefert eine Menge interessanter Ideen (darunter auch einfache Linux-Kommandos, wie bei https://gist.github.com/willurd/5720255 aufgelistet).

Da ich ohnehin einen Apachen auf einem Raspi laufen habe, bot sich dieser für mich an.

Für ACME benötigt man Software, die automatisiert Zertifikate herunterlädt, einen Zertifikats-Roboter kurz _Certbot_, eine Auswahl solcher beschreibt _Let's Encrypt_ unter https://letsencrypt.org/docs/client-options/.

Ich persönlich verwende entgegen der Empfehlung von _Let's Encrypt_ nicht deren Favoriten (den Certbot der EFF), sondern das bash-basierte getssl. Das rührt nur daher, dass meine Bash-Kenntnisse ausgeprägter sind, als meine python-Kenntnisse. Hier sollte jeder das wählen, was ihm liegt.
Wenn im weiteren Text das Wort _Certbot_ verwendet wird, so bezieht sich dies auf ein beliebiges der eben erwähnten Programme (z. B. EFF-certbot, getssl).

# Wieso noch eine Anleitung?

Im diesem Beitrag geht es darum, wie man die Fritzbox per Namen und Zertifikat über eine sichere Verbindung erreichbar macht.

Dazu gibt es im Internet viele, auch gute, Anleitungen. Sollten Sie Ihr Heimnetz und Ihre Internet-Anbindung hauptsächlich oder ausschließlich mit IPv4 betreiben, so sind diese Anleitungen sicher gut. <br>
Aber wenn man ernsthaft auf IPv6 umsteigt, wirft dies im Zusammenhang mit _Let's Encrypt_ Probleme auf.
Denn wenn der Server, für den man ein Zertifikat erlangen will, sowohl mit seiner IPv4 (A-Record) als auch mit seiner IPv6 (AAAA-Record) im DNS verzeichnet ist, verwenden die Server von _Let's Encrypt_ eine IPv6 Verbindung zur IPv6 der FRITZ!Box, anstelle der vorher verwendeten IPv4. <br>
Bei IPv4 funktionierte das, weil in der Fritzbox per Network-Address-Translation (NAT) der Port 80 (HTTP) an den Webserver weitergeleitet wird. Es ist also unter **ein und derselben IPv4** sowohl die FRITZ!Box per HTTPS als auch ein Webserver  im Heimnetz per HTTP aus dem Internet erreichbar.

Unter IPv6 gibt es kein NAT, stattdessen ist (entsprechende Firewall-Freischaltungen vorausgesetzt) die FRITZ!Box unter **einer** IPv6, der Webserver jedoch unter einer **zweiten, anderen** IPv6 erreichbar.

Nun hat man aber nur **einen** Namen und zwar den auf den auch das Zertifikat ausgestellt werden soll. Also Sackgasse?

Nein, trotzdem kann man mit ein wenig Fantasie auch unter IPv6 ein Zertifikat erhalten und zwar so:
1. Unmittelbar bevor man den Vorgang startet, wird im DynDNS für den Namen die IPv6 des Webservers hinterlegt (anstelle der IPv6 der FRITZ!Box).
2. Man startet den _Certbot_ zur Zertifikatserlangung, die Challenge muss dabei auf den Webserver kopiert werden.
3. Nach Download des Zertifikats startet der _Certbot_ den Upload des Zertifikats auf die FRITZ!Box - per SOAP-Request (z. B. mit curl oder wget).
4. Im DynDNS wieder die IPv6 der FRITZ!Box hinterlegt.

Einziger Schönheitsfehler: Während obiger Prozedur ist die FRITZ!Box nicht unter ihrem DNS-Namen per IPv6 erreichbar. Sollte irgendein Problem auftreten, so ist die FRITZ!Box nach wie vor unter Ihrer IPv6-Adresse als auch unter Ihrer IPv4-Adresse  erreichbar, nur eben nicht unter Ihrem Namen.

## Wie ich zu diesen Erkenntnissen gelangte
### Mein Provider unterstützte auf einmal IPv6

Ohne irgendeine Ankündigung unterstützte mein Provider IPv6.
Dass ich auf einmal auch über IPv6 mit dem Internet verbunden  bin, habe ich eine Weile lang überhaupt nicht bemerkt. 
Es fiel mir erst auf als ich wieder mal ins WebGUI meiner FRITZ!Box sah.

Und nachdem auch die IPv6 meiner FRITZ!Box im DynDNS eingetragen war, bemerkte ich, dass der _Certbot_ nicht mehr funktionierte (weil _Let's Encrypt_ offenbar IPv6 bevorzugt und der _Certbot_ die Challenge wie immer auf den Websserver kopierte, _Let's Encrypt_ aber von der IPv6 der FRITZ!Box per HTTP laden wollte).

Das bisher verwendete SSL-Zertifikat funktionierte mit IPv6 prächtig. Aber es läuft eben ab, deswegen braucht man einen funktionierenden _Certbot_.

Welches Protokoll (v4 oder v6) verwendet wird, hängt übrigens sowohl vom Betriebssystem, als auch von der Anwendung ab[^1]. 
[^1]: Interessant finde ich hierbei auch Android: Ist man per WLAN verbunden bevorzugt es IPv4, per Mobilfunk bevorzugt es IPv6. Ändern lässt sich das nicht.

Die _Let's Encrypt_ Server bevorzugen IPv6 um die Antworten abzuholen. Da es aber unter IPv6 kein NAT mehr gibt, weil man den Webserver ja nun unter seiner eigenen IPv6 erreichen kann (freischalten muss man das natürlich), geht das erst einmal in die Hose.

Das bedeutet, dass der DNS-Name der Fritzbox zum Zeitpunkt der Zertifikatsanfrage bei _Let's Encrypt_ auf die IPv6-Adresse des Webservers zeigen muss, nicht auf die der FRITZ!Box!

Aber es steckt ja schon im Namen DynDNS, dass man diese Adresse sehr dynamisch ändern kann.

Damit steht der Plan fest:
1. IPv6-Adresse des Webservers im DNS eintragen.
2. Zertifikat abrufen
3. Wieder die IPv6-Adresse der FRITZ!Box im DNS eintragen.
Fertig!<br>
Einziges Manko: 
Während des Zertifikatsabrufs ist die FRITZ!Box nicht unter Ihrem Namen erreichbar. Da man das Zertifikat nur alle 90 Tage erneuern muss, die ganze Prozedur also nicht einmal monatlich braucht und sie nur Minuten läuft, ist das nicht wirklich problematisch. 

Und sollte der Vorgang vor Schritt 3 abbrechen, ist die FRITZ!Box immer noch durch Adresseingabe per IPv6 (und auch nach wie vor per IPv4) erreichbar.

# Erreichbarkeit der FRITZ!Box

Die Fritzbox ist automatisch unter Ihrer IPv6-Adresse erreichbar, man kann sie also sowohl unter https://nnn.nnn.nnn.nnn/ per IPv4 als auch unter https://[xxxx:xxxx:xxxx:xxxx:xxxx:xxxx]/ per IPv6 (unter ignorieren jeglicher Zertifikatswarnungen).

Damit das alles ohne Zertifikatsprobleme funktioniert, trägt man für die FritzBOX beim Provider per DynDNS, z. B. als  meinebox.meine-domain.de und zwar sowohl mit IPv4- als auch mit IPv6-Adresse ein. ein.

Damit ist die Box dann auch mit ihrem Namen erreichbar, per https://meinebox.meine-domain.de/  erreichbar.

Das bisherige Zertifikat funktioniert auch weiterhin, es ist ja namensbasiert. Nur leider läuft es 90 Tage nach Erstellung ab.

Es gilt also, wieder automatisiert ein neues zu beschaffen. 

Dazu braucht es;
Was braucht man dazu:
1. getssl (https://github.com/srvrco/getssl) auf dem Webserver (oder einen anderen _Certbot_).
2. ein Skript, welches das Zertifikat per SOAP  auf die FritzBOX hochlädt, ich nenne es mal  pushsslcert2fb.
3. ein Skript welches den DynDNS-Eintrag ändern kann, ich nenne es ddfbset.
4. ein Skript, welches die externe IPv6 der Fritzbox ermittelt, ich nenne es myip. Es wird von ddfbset verwendet.
5. ein Skript, welches die IPv6-Adresse des Webservers (auf dem es läuft) ermittelt, ich nenne es fritzip. Es wird von ddfbset verwendet.

Und dann geht man wie folgt vor:
1. DynDNS auf Webserver IPv6 zeigen lassen.
2. Zertifikat bei Let's Encrypt anfordern.
3. DynDNS wieder auf FritzBOX zeigen lassen.

In Kommandos:<br>
1. `ddfbset -to-server  fritz.meine-domain.de`<br>
2. `getssl fritz.meine-domain.de`<br>
3. `ddfbset -to-fritzbox fritz.meine-domain.de`<br>

In `cron` auf dem Webserver liesse sich das dann in etwa so automatisieren:

```
# **** getssl FRITZ!Box ****
# Every 1st and 15th of the month at 9:15am
# Regular cron jobs for update of SSL certs
15 9 1,15 * * root  /usr/local/bin/ddfbset -to-server &
& /usr/local/bin/getssl --quiet --upgrade fritz.meine-domain.de
 && /usr/local/bin/ddfbset -to-fritzbox >> /var/log/getssl.log
```
### Skripte 

#### ddfbset

 Hier ist das Skript zu finden: [https://github.com/himbeer-toni/UserScripts/blob/main/ddfbset](https://github.com/himbeer-toni/UserScripts/blob/main/ddfbset)
 
#### myip
Hier ist das Skript zu finden: [https://github.com/himbeer-toni/UserScripts/blob/main/myip](https://github.com/himbeer-toni/UserScripts/blob/main/myip)

#### fritzip
Hier ist das Skript zu finden: [https://github.com/himbeer-toni/UserScripts/blob/main/fritzip](https://github.com/himbeer-toni/UserScripts/blob/main/fritzip)

#### pushsslcert2fb
Hier ist das Skript zu finden: [https://github.com/himbeer-toni/UserScripts/blob/main/pushsslcert2fb](https://github.com/himbeer-toni/UserScripts/blob/main/pushsslcert2fb)
