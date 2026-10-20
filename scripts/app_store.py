#!/usr/bin/env python3
"""App Store Connect por API para VallartApp (misma llave que Omeyocan: tools/app_store.py de ese repo).

    python3 scripts/app_store.py estado        # versión, build, ficha, precio y disponibilidad
    python3 scripts/app_store.py ficha         # nombre, subtítulo, descripción, keywords, URLs, categorías, copyright
    python3 scripts/app_store.py edad          # cuestionario de clasificación por edad
    python3 scripts/app_store.py precio        # gratis + disponible en todos los países
    python3 scripts/app_store.py build         # asigna a la versión 1.0 el build procesado más nuevo
    python3 scripts/app_store.py capturas      # sube build/screenshots/{es,en} (scripts/screenshots.sh)
    python3 scripts/app_store.py get <ruta>    # lee cualquier cosa de la API

Todo es ENSAYO si no lleva --de-verdad: dice qué haría sin mandar nada. Nada de esto manda la app a revisión.
La llave: ~/.appstoreconnect/private_keys/AuthKey_<KID>.p8 (fuera del repo).
"""
import base64
import json
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

API = "https://api.appstoreconnect.apple.com"
KID = "97D6RCK83D"
ISS = "dd6e8007-ca28-448d-a990-397fd63ad267"
P8 = Path.home() / f".appstoreconnect/private_keys/AuthKey_{KID}.p8"
APP = "6825114276"
WEB = "https://vallartapp.vercel.app"
DE_VERDAD = "--de-verdad" in sys.argv

# ---------------------------------------------------------------- textos de la ficha

COPYRIGHT = "2026 Eduardo Benavides"
CATEGORIAS = ("TRAVEL", "FOOD_AND_DRINK")

FICHA = {
    "es-MX": {
        "name": "VallartApp",
        "subtitle": "Guía de Puerto Vallarta",
        "keywords": "puerto,riviera nayarit,restaurantes,playas,bares,hoteles,tours,eventos,mapa,yates,sayulita,guia",
        "promotionalText": "Más de 270 lugares, eventos y playas de Puerto Vallarta y la Riviera Nayarit, "
                           "en un mapa y en tu idioma. Gratis.",
        "description": """Descubre lo mejor de Puerto Vallarta y la Riviera Nayarit en una sola app, gratis.

VallartApp reúne más de 270 lugares seleccionados: restaurantes, bares y vida nocturna, hoteles, playas, tours y actividades, renta de yates, spas, tiendas y renta de autos y motos. Desde el Centro y la Zona Romántica hasta Marina Vallarta, Nuevo Vallarta, Bucerías, Punta Mita, Sayulita, San Pancho y Yelapa.

• EXPLORA: recomendaciones del editor, lo más popular y lo que es tendencia.
• MAPA: todos los lugares en el mapa, con tu ubicación para ver qué tienes cerca.
• EVENTOS: conciertos, fiestas, mercados y eventos de temporada, con fecha, lugar y boletos.
• BUSCA Y FILTRA: por categoría, zona, precio o abiertos ahora.
• DETALLES: fotos, horarios, teléfono, sitio web, Instagram y cómo llegar.
• FAVORITOS: guarda los lugares que quieres visitar en tu viaje.
• RESEÑAS: califica y comparte tu experiencia con otros viajeros.
• AVISOS: entérate de eventos y novedades de la ciudad.

Disponible en español e inglés. Úsala sin cuenta, o entra con Apple o tu correo para guardar lugares y escribir reseñas.

¿Tienes un negocio en Vallarta? Escríbenos desde la app para aparecer.""",
    },
    "en-US": {
        "name": "VallartApp",
        "subtitle": "Puerto Vallarta Travel Guide",
        "keywords": "puerto,riviera nayarit,mexico,restaurants,beaches,bars,hotels,tours,events,map,sayulita,guide",
        "promotionalText": "270+ places, events and beaches in Puerto Vallarta and Riviera Nayarit, "
                           "on a map and in your language. Free.",
        "description": """Discover the best of Puerto Vallarta and Riviera Nayarit in one free app.

VallartApp brings together 270+ hand-picked places: restaurants, bars and nightlife, hotels, beaches, tours and activities, yacht rentals, spas, shopping, and car and scooter rentals. From Downtown and the Romantic Zone to Marina Vallarta, Nuevo Vallarta, Bucerías, Punta Mita, Sayulita, San Pancho and Yelapa.

• EXPLORE: editor's picks, what's popular and what's trending.
• MAP: every place on the map, with your location to see what's nearby.
• EVENTS: concerts, parties, markets and seasonal events, with dates, venues and tickets.
• SEARCH & FILTER: by category, neighborhood, price or open now.
• DETAILS: photos, hours, phone, website, Instagram and directions.
• FAVORITES: save the places you want to visit on your trip.
• REVIEWS: rate places and share your experience with other travelers.
• ALERTS: hear about events and news around town.

Available in English and Spanish. Use it without an account, or sign in with Apple or email to save places and write reviews.

Own a business in Vallarta? Contact us from the app to get listed.""",
    },
}

# Clasificación por edad: lugares de bares/vida nocturna → alcohol "poco frecuente/leve"; las reseñas son
# contenido de usuarios. Todo lo demás, nada.
EDAD_NIVEL = {"alcoholTobaccoOrDrugUseOrReferences": "INFREQUENT_OR_MILD"}
EDAD_SI = {"userGeneratedContent"}
# Campos de nivel (NONE / INFREQUENT_OR_MILD / FREQUENT_OR_INTENSE) y de sí/no del cuestionario actual de Apple.
EDAD_NIVELES = ("alcoholTobaccoOrDrugUseOrReferences", "contests", "gamblingSimulated", "gunsOrOtherWeapons",
                "horrorOrFearThemes", "matureOrSuggestiveThemes", "medicalOrTreatmentInformation",
                "profanityOrCrudeHumor", "sexualContentGraphicAndNudity", "sexualContentOrNudity",
                "violenceCartoonOrFantasy", "violenceRealistic", "violenceRealisticProlongedGraphicOrSadistic")
EDAD_SINO = ("advertising", "ageAssurance", "gambling", "healthOrWellnessTopics", "lootBox", "messagingAndChat",
             "parentalControls", "unrestrictedWebAccess", "userGeneratedContent")

# ---------------------------------------------------------------- API (igual que Omeyocan)


def _b64(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


_token = (0, "")


def token():
    """JWT ES256 de 20 min firmado con openssl: la firma DER se pasa a r||s de 32 bytes cada uno."""
    global _token
    ahora = int(time.time())
    if _token[0] > ahora + 60:
        return _token[1]
    if not P8.exists():
        sys.exit(f"No está la llave: {P8}")
    cab = _b64(json.dumps({"alg": "ES256", "kid": KID, "typ": "JWT"}).encode())
    cue = _b64(json.dumps({"iss": ISS, "iat": ahora, "exp": ahora + 1200, "aud": "appstoreconnect-v1"}).encode())
    der = subprocess.run(["openssl", "dgst", "-sha256", "-sign", str(P8)], input=f"{cab}.{cue}".encode(),
                         capture_output=True, check=True).stdout
    i = 2 if der[1] < 0x80 else 3
    r = der[i + 2:i + 2 + der[i + 1]]
    i += 2 + der[i + 1]
    s = der[i + 2:i + 2 + der[i + 1]]
    firma = r.lstrip(b"\0").rjust(32, b"\0") + s.lstrip(b"\0").rjust(32, b"\0")
    _token = (ahora + 1200, f"{cab}.{cue}.{_b64(firma)}")
    return _token[1]


def api(metodo, ruta, cuerpo=None, params=None):
    url = API + ruta + ("?" + urllib.parse.urlencode(params, safe="[],") if params else "")
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(url, data=datos, method=metodo,
                                 headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            texto = r.read()
            return r.status, json.loads(texto) if texto else {}
    except urllib.error.HTTPError as e:
        texto = e.read()
        try:
            return e.code, json.loads(texto)
        except ValueError:
            return e.code, {"errors": [{"detail": texto.decode(errors="replace")[:300]}]}


def errores(d):
    return " · ".join(e.get("detail") or e.get("title", "") for e in d.get("errors", [])) or json.dumps(d)[:300]


def leer(ruta, params=None, ok=(200,)):
    e, d = api("GET", ruta, params=params)
    if e not in ok:
        sys.exit(f"Apple dijo {e} al leer {ruta}: {errores(d)}")
    return d


def hacer(que, metodo, ruta, cuerpo=None):
    print(f"  → {que}")
    if not DE_VERDAD:
        print(f"      (ensayo: {metodo} {ruta})")
        return None
    e, d = api(metodo, ruta, cuerpo)
    if e >= 300:
        sys.exit(f"      Apple dijo {e}: {errores(d)}")
    print("      hecho")
    return d


def rel(tipo, id_):
    return {"data": {"type": tipo, "id": id_}}


# ---------------------------------------------------------------- lecturas

def version():
    d = leer(f"/v1/apps/{APP}/appStoreVersions", {"filter[platform]": "IOS"})
    editables = [v for v in d["data"] if v["attributes"]["appStoreState"] in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED",
                                                                              "REJECTED", "METADATA_REJECTED")]
    if not editables:
        sys.exit("No hay una versión editable.")
    return editables[0]


def app_info():
    d = leer(f"/v1/apps/{APP}/appInfos")
    return next(i for i in d["data"] if i["attributes"]["state"] != "READY_FOR_DISTRIBUTION")


def existe(ruta):
    """Apple a veces contesta 200 sin datos (o 404) cuando algo no está definido."""
    e, d = api("GET", ruta)
    return e == 200 and bool(d.get("data"))


def builds():
    return leer("/v1/builds", {"filter[app]": APP, "sort": "-uploadedDate", "limit": "10",
                               "fields[builds]": "version,processingState,uploadedDate,expired"})["data"]


# ---------------------------------------------------------------- órdenes

def cmd_estado():
    v = version()
    print(f"Versión {v['attributes']['versionString']}: {v['attributes']['appStoreState']}")
    b = leer(f"/v1/appStoreVersions/{v['id']}/build", ok=(200,))
    print("  build asignado:", (b.get("data") or {}).get("attributes", {}).get("version", "ninguno"))
    for x in builds():
        a = x["attributes"]
        print(f"  build {a['version']}: {a['processingState']} (subido {a['uploadedDate'][:16]})")
    for loc in leer(f"/v1/appStoreVersions/{v['id']}/appStoreVersionLocalizations")["data"]:
        a = loc["attributes"]
        print(f"  ficha {a['locale']}: descripción {'sí' if a.get('description') else 'NO'}, "
              f"keywords {'sí' if a.get('keywords') else 'NO'}, soporte {a.get('supportUrl') or 'NO'}")
    print("  precio:", "definido" if existe(f"/v1/appPriceSchedules/{APP}/manualPrices") else "NO definido")
    print("  disponibilidad:", "definida" if existe(f"/v1/apps/{APP}/appAvailabilityV2") else "NO definida")


def cmd_ficha():
    for loc, t in FICHA.items():
        assert len(t["keywords"]) <= 100, (loc, len(t["keywords"]))
        assert len(t["subtitle"]) <= 30 and len(t["promotionalText"]) <= 170 and len(t["description"]) <= 4000, loc

    info = app_info()
    print("Nombre, subtítulo y URL de privacidad")
    existentes = {x["attributes"]["locale"]: x["id"]
                  for x in leer(f"/v1/appInfos/{info['id']}/appInfoLocalizations")["data"]}
    for loc, t in FICHA.items():
        attrs = {"name": t["name"], "subtitle": t["subtitle"], "privacyPolicyUrl": f"{WEB}/privacy"}
        if loc in existentes:
            hacer(f"{loc}: actualizar", "PATCH", f"/v1/appInfoLocalizations/{existentes[loc]}",
                  {"data": {"type": "appInfoLocalizations", "id": existentes[loc], "attributes": attrs}})
        else:
            hacer(f"{loc}: crear", "POST", "/v1/appInfoLocalizations",
                  {"data": {"type": "appInfoLocalizations", "attributes": {"locale": loc, **attrs},
                            "relationships": {"appInfo": rel("appInfos", info["id"])}}})

    print(f"Categorías: {' + '.join(CATEGORIAS)}")
    hacer("asignar categorías", "PATCH", f"/v1/appInfos/{info['id']}",
          {"data": {"type": "appInfos", "id": info["id"], "relationships": {
              "primaryCategory": rel("appCategories", CATEGORIAS[0]),
              "secondaryCategory": rel("appCategories", CATEGORIAS[1])}}})

    v = version()
    print(f"Versión {v['attributes']['versionString']}: copyright y textos")
    hacer(f"copyright «{COPYRIGHT}»", "PATCH", f"/v1/appStoreVersions/{v['id']}",
          {"data": {"type": "appStoreVersions", "id": v["id"], "attributes": {"copyright": COPYRIGHT}}})
    existentes = {x["attributes"]["locale"]: x["id"]
                  for x in leer(f"/v1/appStoreVersions/{v['id']}/appStoreVersionLocalizations")["data"]}
    for loc, t in FICHA.items():
        attrs = {"description": t["description"], "keywords": t["keywords"], "promotionalText": t["promotionalText"],
                 "supportUrl": f"{WEB}/support", "marketingUrl": WEB}
        if loc in existentes:
            hacer(f"{loc}: descripción, keywords y URLs", "PATCH",
                  f"/v1/appStoreVersionLocalizations/{existentes[loc]}",
                  {"data": {"type": "appStoreVersionLocalizations", "id": existentes[loc], "attributes": attrs}})
        else:
            hacer(f"{loc}: crear con descripción, keywords y URLs", "POST", "/v1/appStoreVersionLocalizations",
                  {"data": {"type": "appStoreVersionLocalizations", "attributes": {"locale": loc, **attrs},
                            "relationships": {"appStoreVersion": rel("appStoreVersions", v["id"])}}})


def cmd_edad():
    info = app_info()
    d = leer(f"/v1/appInfos/{info['id']}/ageRatingDeclaration")["data"]
    attrs = {k: EDAD_NIVEL.get(k, "NONE") for k in EDAD_NIVELES}
    attrs.update({k: k in EDAD_SI for k in EDAD_SINO})
    for k, val in sorted(attrs.items()):
        print(f"  {k} = {val}")
    hacer("guardar clasificación", "PATCH", f"/v1/ageRatingDeclarations/{d['id']}",
          {"data": {"type": "ageRatingDeclarations", "id": d["id"], "attributes": attrs}})


def cmd_precio():
    if existe(f"/v1/appPriceSchedules/{APP}/manualPrices"):
        print("Precio: ya definido.")
    else:
        puntos = leer(f"/v1/apps/{APP}/appPricePoints", {"filter[territory]": "USA", "limit": "200",
                                                         "fields[appPricePoints]": "customerPrice"})["data"]
        gratis = next(p["id"] for p in puntos if float(p["attributes"]["customerPrice"]) == 0)
        hacer("precio: gratis (base EE. UU.)", "POST", "/v1/appPriceSchedules", {
            "data": {"type": "appPriceSchedules", "relationships": {
                "app": rel("apps", APP), "baseTerritory": rel("territories", "USA"),
                "manualPrices": {"data": [{"type": "appPrices", "id": "${gratis}"}]}}},
            "included": [{"type": "appPrices", "id": "${gratis}", "attributes": {"startDate": None},
                          "relationships": {"appPricePoint": rel("appPricePoints", gratis)}}]})

    if existe(f"/v1/apps/{APP}/appAvailabilityV2"):
        print("Disponibilidad: ya definida.")
        return
    territorios = [t["id"] for t in leer("/v1/territories", {"limit": "200"})["data"]]
    hacer(f"disponible en {len(territorios)} países y en los nuevos", "POST", "/v2/appAvailabilities", {
        "data": {"type": "appAvailabilities", "attributes": {"availableInNewTerritories": True},
                 "relationships": {"app": rel("apps", APP), "territoryAvailabilities": {
                     "data": [{"type": "territoryAvailabilities", "id": f"${{{t}}}"} for t in territorios]}}},
        "included": [{"type": "territoryAvailabilities", "id": f"${{{t}}}", "attributes": {"available": True},
                      "relationships": {"territory": rel("territories", t)}} for t in territorios]})


CAPTURAS = {"es-MX": "es", "en-US": "en"}   # carpeta de build/screenshots/ (scripts/screenshots.sh)
TIPO_CAPTURA = "APP_IPHONE_67"              # iPhone 6.9" (1320×2868)


def cmd_capturas():
    import hashlib
    raiz = Path(__file__).resolve().parent.parent / "build/screenshots"
    v = version()
    locs = {x["attributes"]["locale"]: x["id"]
            for x in leer(f"/v1/appStoreVersions/{v['id']}/appStoreVersionLocalizations")["data"]}
    for loc, carpeta in CAPTURAS.items():
        pngs = sorted((raiz / carpeta).glob("*.png"))
        if not pngs:
            sys.exit(f"No hay capturas en {raiz / carpeta}: corre scripts/screenshots.sh")
        print(f"{loc}: {len(pngs)} capturas")
        sets = leer(f"/v1/appStoreVersionLocalizations/{locs[loc]}/appScreenshotSets")["data"]
        actual = next((s for s in sets if s["attributes"]["screenshotDisplayType"] == TIPO_CAPTURA), None)
        if actual:
            for vieja in leer(f"/v1/appScreenshotSets/{actual['id']}/appScreenshots")["data"]:
                hacer(f"borrar captura anterior {vieja['attributes']['fileName']}", "DELETE",
                      f"/v1/appScreenshots/{vieja['id']}")
            set_id = actual["id"]
        else:
            d = hacer(f"crear juego de capturas {TIPO_CAPTURA}", "POST", "/v1/appScreenshotSets",
                      {"data": {"type": "appScreenshotSets", "attributes": {"screenshotDisplayType": TIPO_CAPTURA},
                                "relationships": {"appStoreVersionLocalization": rel("appStoreVersionLocalizations",
                                                                                     locs[loc])}}})
            set_id = d["data"]["id"] if d else "(nuevo)"
        for png in pngs:
            datos = png.read_bytes()
            d = hacer(f"subir {png.name}", "POST", "/v1/appScreenshots",
                      {"data": {"type": "appScreenshots",
                                "attributes": {"fileName": png.name, "fileSize": len(datos)},
                                "relationships": {"appScreenshotSet": rel("appScreenshotSets", set_id)}}})
            if not d:
                continue
            for op in d["data"]["attributes"]["uploadOperations"]:
                parte = datos[op["offset"]:op["offset"] + op["length"]]
                req = urllib.request.Request(op["url"], data=parte, method=op["method"],
                                             headers={h["name"]: h["value"] for h in op["requestHeaders"]})
                urllib.request.urlopen(req, timeout=120).read()
            hacer(f"confirmar {png.name}", "PATCH", f"/v1/appScreenshots/{d['data']['id']}",
                  {"data": {"type": "appScreenshots", "id": d["data"]["id"],
                            "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(datos).hexdigest()}}})


def cmd_build():
    v = version()
    listos = [b for b in builds() if b["attributes"]["processingState"] == "VALID" and not b["attributes"]["expired"]]
    if not listos:
        sys.exit("Todavía no hay un build procesado (VALID). Apple tarda 5–30 min después de subirlo.")
    b = listos[0]
    hacer(f"asignar build {b['attributes']['version']} a la versión {v['attributes']['versionString']}", "PATCH",
          f"/v1/appStoreVersions/{v['id']}/relationships/build", rel("builds", b["id"]))


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--de-verdad"]
    orden = args[0] if args else "estado"
    if orden == "get":
        print(json.dumps(leer(args[1], ok=(200, 404)), indent=1, ensure_ascii=False)[:6000])
    else:
        {"estado": cmd_estado, "ficha": cmd_ficha, "edad": cmd_edad, "precio": cmd_precio,
         "build": cmd_build, "capturas": cmd_capturas}[orden]()
        if not DE_VERDAD and orden != "estado":
            print("\n(ensayo: no se mandó nada; con --de-verdad se aplica)")
