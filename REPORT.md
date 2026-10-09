# Arvestustöö raport

**Nimi:** Morten Oliver Sõlg  
**Variant:** sa-test (AnnaKarutina)  
**Kuupäev:** 09.10.2026

## Probleem 1 – Vale kettakasutuse arvutamine

- **Skript:** `scripts/disk_check.sh`
- **Mida skript näiliselt tegi:** Kontrollis süsteemi kettakasutust ja andis teada, kas kettaruumi kasutus on normis.
- **Mis oli tegelikult vale:** Skript kasutas `df` käsu neljandat veergu, mis näitab vaba kettaruumi, mitte kasutusprotsenti. Seetõttu näitas skript kettakasutuseks 27%, kuigi tegelik kasutus oli 5%.
- **Kuidas vea avastasin:** Võrdlesin skripti väljundit Linuxi `df` käsu tulemusega.
- **Millise käsuga kontrollisin:** `df -h /`
- **Parandus:** Muutsin skripti kasutama `df -P /` viiendat veergu, eemaldades protsendimärgi `awk` abil.
- **Kuidas kontrollisin pärast parandust:** Käivitasin uuesti `bash scripts/disk_check.sh` ja võrdlesin tulemust käsuga `df -P /`. Mõlemad näitasid kettakasutuseks 5%.
- **Exit code:** Normaalse kettakasutuse korral `0`.

## Probleem 2 – Kasutajate kontrollimine andis vale tulemuse

- **Skript:** `scripts/user_check.sh`
- **Mida skript näiliselt tegi:** Kontrollis, kas sisestatud kasutaja eksisteerib Linuxi süsteemis.
- **Mis oli tegelikult vale:** Skript kontrollis kasutaja olemasolu ebaõigel viisil ning väitis, et isegi olematu kasutaja eksisteerib. Lisaks aktsepteeris skript tühja kasutajanime.
- **Kuidas vea avastasin:** Käivitasin skripti olemasoleva kasutajaga `root`, olematu kasutajaga `kasutaja_keda_ei_ole` ning tühja sisendiga.
- **Millise käsuga kontrollisin:** `bash scripts/user_check.sh kasutaja_keda_ei_ole` ja `bash scripts/user_check.sh ""`
- **Parandus:** Kasutasin `getent passwd` käsku, mis kontrollib kasutaja olemasolu süsteemi kasutajate andmebaasist. Lisasin tühja sisendi ja argumentide arvu kontrolli.
- **Kuidas kontrollisin pärast parandust:** `root` tuvastati olemasolevana, olematu kasutaja puuduvana ning tühi sisend tekitas veateate.
- **Exit code enne / pärast:** Algne skript andis olematu kasutaja korral vale positiivse tulemuse. Pärast parandust on olemasoleva kasutaja kood `0`, puuduva kasutaja kood `1` ja vigase sisendi kood `2`.

## Probleem 3 – Teenuse olemasolu ei tähenda, et see töötab

- **Skript:** `scripts/service_check.sh`
- **Mida skript näiliselt tegi:** Kontrollis, kas määratud teenus töötab.
- **Mis oli tegelikult vale:** Skript kasutas `systemctl list-unit-files` käsku, mis kontrollis teenuse unit-faili olemasolu, mitte teenuse aktiivset olekut.
- **Kuidas vea avastasin:** Uurisin skripti lähtekoodi ja võrdlesin kontrollimise loogikat käsuga `systemctl is-active`.
- **Millise käsuga kontrollisin:** `systemctl is-active ssh` ja `systemctl is-active olematu_teenus_123`
- **Parandus:** Asendasin kontrolli käsuga `systemctl is-active --quiet`. Lisasin tühja teenusenime kontrolli.
- **Kuidas kontrollisin pärast parandust:** Aktiivne SSH teenus tuvastati töötavana, olematu teenus mittetöötavana ning tühi sisend andis veateate.
- **Exit code pärast:** Töötav teenus `0`, mittetöötav teenus `1`, vigane sisend `2`.

## Probleem 4 – Süsteemiinfo kuvamisel kasutati valesid käske

- **Skript:** `scripts/system_info.sh`
- **Mida skript näiliselt tegi:** Kuvati arvuti hostinimi, kasutajanimi, kerneli versioon, töötamise kestus ja mälu kogumaht.
- **Mis oli tegelikult vale:** Hostinime ja kasutajanime käsud olid vahetuses. Kerneli versiooni asemel kuvati arhitektuuri (`x86_64`), töötamise kestuse asemel kellaaega ning RAM-i asemel swap-mälu mahtu.
- **Kuidas vea avastasin:** Käivitasin skripti ning võrdlesin selle väljundit süsteemi tegelike andmetega.
- **Millise käsuga kontrollisin:** `hostname`, `whoami`, `uname -r`, `uptime -p` ja `free -m`
- **Parandus:** Kasutasin iga välja jaoks õiget Linuxi käsku ning RAM-i saamiseks `free -m` väljundi Mem-rida.
- **Kuidas kontrollisin pärast parandust:** Skript näitas kerneli versiooniks `6.12.107+deb13-amd64`, töötamise kestuseks umbes 2 tundi ja 35 minutit ning mälumahuks 7851 MiB. Need vastasid kontrollkäskude tulemustele.

## Probleem 5 – Varukoopiafail ei olnud tegelik arhiiv

- **Skript:** `scripts/backup.sh`
- **Mida skript näiliselt tegi:** Lõi varukoopia `.tar.gz` failina ning väljastas teate edukast varundamisest.
- **Mis oli tegelikult vale:** Skript kasutas `find` käsku, mis salvestas faili sisse ainult failinimede loendi. Tegemist ei olnud tegeliku TAR-arhiiviga.
- **Kuidas vea avastasin:** Käivitasin varundusskripti ning kontrollisin loodud faili tüüpi ja arhiivi sisu.
- **Millise käsuga kontrollisin:** `file backups/*.tar.gz` ja `tar -tzf backups/*.tar.gz`
- **Parandus:** Asendasin failinimede loendi loomise käsuga `tar -czf`, mis loob päris gzip-tihendusega TAR-arhiivi.
- **Kuidas kontrollisin pärast parandust:** `file` tuvastas gzip-arhiivi, `gzip -t` õnnestus ja `tar -tzf` kuvas kõik kolm faili, sealhulgas `important data.txt`.
- **Exit code enne / pärast:** Enne parandust andis arhiivi avamine koodi `2`. Pärast parandust õnnestus kontroll koodiga `0`.

## Probleem 6 – Varukoopia edukust kontrolliti valesti

- **Skript:** `scripts/backup.sh`
- **Mida skript näiliselt tegi:** Kontrollis, kas varukoopia loomine õnnestus.
- **Mis oli tegelikult vale:** Skript kasutas kontrolli `[ -s "$ARCHIVE" ]`, mis kontrollis ainult faili olemasolu ja suurust. Skript teatas edukast varundamisest isegi siis, kui arhiivi ei saanud taastada.
- **Kuidas vea avastasin:** Algne skript väljastas `Varukoopia valmis` ja lõpetamiskoodi `0`, kuid `tar -tzf` näitas, et fail ei olnud gzip-vormingus.
- **Millise käsuga kontrollisin:** `file`, `gzip -t`, `tar -tzf`, `tar -xzf` ja `diff -r`
- **Parandus:** Lisasin arhiivi loomise õnnestumise kontrolli ning `gzip -t` ja `tar -tzf` kontrollid. Vigase arhiivi korral lõpetab skript veaga.
- **Kuidas kontrollisin pärast parandust:** Taastasin arhiivi kausta `/tmp/backup-test` ning võrdlesin taastatud faile originaalidega käsuga `diff -r testdata/source /tmp/backup-test/source`. Erinevusi ei leitud ja lõpetamiskood oli `0`. Ka tühikuga failinimi säilis.
- **Exit code enne / pärast:** Algne skript tagastas vigase varukoopia puhul `0`. Parandatud skript tagastab eduka varunduse puhul `0` ja tuvastatud vea puhul mitte-null koodi.

## Uus funktsionaalsus

- **Mida lisasin:** Lisasin uue skripti `scripts/health_report.sh`, mis võimaldab teha mitu süsteemikontrolli korraga ning salvestada tulemused logifaili.
- **Kuidas töötab:** Skript käivitab `system_info.sh`, `disk_check.sh` ja `service_check.sh` skriptid, kuvab nende tulemused terminalis ning salvestab need faili `logs/health_report.log`.
- **Lisavõimalused:** Iga käivitamise juurde lisatakse kuupäev ja kellaaeg. Varasemaid logisid ei kirjutata üle. Kui mõni kontroll ebaõnnestub, tagastab skript veakoodi.
- **Käivitamine:** `bash scripts/health_report.sh`
- **Kontrollimine:** Käivitasin uue skripti ja kontrollisin logifaili käsuga `cat logs/health_report.log`. Kõik kontrollid õnnestusid ning skript tagastas koodi `0`. Logikirjete arvu kontrollisin käsuga `grep -c "=== Süsteemikontroll:" logs/health_report.log`.

## Kokkuvõte

Töö käigus kontrollisin viit olemasolevat Bash-skripti ning parandasin nende sisulised vead. Kõige olulisem oli veenduda, et skriptid ei kuvaks lihtsalt usutavaid tulemusi, vaid kasutaksid õigeid süsteemiandmeid.

Kontrollimiseks kasutasin Linuxi käske ning võrdlesin skriptide tulemusi tegelike süsteemiandmetega. Varunduse puhul kontrollisin lisaks arhiivi taastamist ja failide terviklikkust.

Parandused salvestasin Git-repositooriumisse eraldi commit'idena. Lisaks lisasin uue süsteemikontrolli ja logimise funktsionaalsuse.
