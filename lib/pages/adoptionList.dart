import 'package:auto_size_text/auto_size_text.dart';
import 'package:carepetsapp/models/adoption.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/pages/viewAdoption.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdoptionList extends StatefulWidget {
  @override
  _AdoptionListState createState() => _AdoptionListState();
}

class _AdoptionListState extends State<AdoptionList> {
  //Variables
  final db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  OverlayEntry? _overlayEntry;
  OverlayState? _overlay;
  bool _isDog = false,
      _isCat = false,
      _isRabbit = false,
      _isHamster = false,
      _isFerret = false,
      _isGuineaPig = false,
      _isChinchilla = false,
      _isBird = false,
      _isFish = false,
      _isTortoise = false,
      _isHedgehog = false,
      _isHorse = false,
      _isOther = false,
      _isMale = false,
      _isFemale = false,
      _isACoruna = false,
      _isAlava = false,
      _isAlbacete = false,
      _isAlicante = false,
      _isAlmeria = false,
      _isAsturias = false,
      _isAvila = false,
      _isBadajoz = false,
      _isBarcelona = false,
      _isBurgos = false,
      _isCaceres = false,
      _isCadiz = false,
      _isCantabria = false,
      _isCastellon = false,
      _isCeuta = false,
      _isCiudadReal = false,
      _isCordoba = false,
      _isCuenca = false,
      _isFormentera = false,
      _isGirona = false,
      _isGranada = false,
      _isGuadalajara = false,
      _isGuipuzcoa = false,
      _isHuelva = false,
      _isHuesca = false,
      _isIbiza = false,
      _isJaen = false,
      _isLaRioja = false,
      _isLeon = false,
      _isLerida = false,
      _isLugo = false,
      _isMadrid = false,
      _isMalaga = false,
      _isMallorca = false,
      _isMenorca = false,
      _isMurcia = false,
      _isNavarra = false,
      _isOrense = false,
      _isPalencia = false,
      _isPontevedra = false,
      _isSalamanca = false,
      _isSegovia = false,
      _isSevilla = false,
      _isSoria = false,
      _isTarragona = false,
      _isTeruel = false,
      _isToledo = false,
      _isValencia = false,
      _isValladolid = false,
      _isVizcaya = false,
      _isZamora = false,
      _isZaragoza = false,
      filterAnimals = false,
      filterGender = false,
      filterProvince = false;

  List<String> typeListAnimals = [
    "Perro",
    "Gato",
    "Conejo",
    "Hamster",
    "Hurón",
    "Cobaya",
    "Chinchilla",
    "Pájaro",
    "Pez",
    "Tortuga",
    "Erizo",
    "Caballo",
    "Otro",
  ];
  List<String> genderListAnimals = [
    "Macho",
    "Hembra",
  ];
  List<String> provinceListAnimals = [
    "A Coruña",
    "Alava",
    "Albacete",
    "Alicante",
    "Almería",
    "Asturias",
    "Avila",
    "Badajoz",
    "Barcelona",
    "Burgos",
    "Cáceres",
    "Cádiz",
    "Cantabria",
    "Castellón",
    "Ceuta",
    "Ciudad Real",
    "Córdoba",
    "Cuenca",
    "Formentera",
    "Girona",
    "Granada",
    "Guadalajara",
    "Guipuzcoa",
    "Huelva",
    "Huesca",
    "Ibiza",
    "Jaén",
    "La Rioja",
    "León",
    "Lérida",
    "Lugo",
    "Madrid",
    "Málaga",
    "Mallorca",
    "Menorca",
    "Murcia",
    "Navarra",
    "Orense",
    "Palencia",
    "Pontevedra",
    "Salamanca",
    "Segovia",
    "Sevilla",
    "Soria",
    "Tarragona",
    "Teruel",
    "Toledo",
    "Valencia",
    "Valladolid",
    "Vizcaya",
    "Zamora",
    "Zaragoza",
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _overlay = Overlay.of(context)!;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
        maintainState: true,
        builder: (context) => Positioned(
            right: 30,
            top: 200,
            width: 300,
            height: 300,
            child: Material(
                elevation: 4.0,
                child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                        appBar: const TabBar(labelColor: Colors.black, tabs: [
                          Tab(child: AutoSizeText('Tipo')),
                          Tab(child: AutoSizeText('Sexo')),
                          Tab(child: AutoSizeText('Provincia'))
                        ]),
                        body: TabBarView(children: <Widget>[
                          Container(child: getFilterType()),
                          Container(child: getFilterGender()),
                          Container(child: getFilterProvince()),
                        ]),
                        bottomNavigationBar: SizedBox(
                          child: ListTile(
                              title: const Text('Listo'),
                              onTap: () =>
                                  {setState(() {}), _overlayEntry?.remove()}),
                        ))))));
  }

  getFilterType() {
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      ListTile(
          title: const Text('Perro'),
          trailing: Checkbox(
            value: _isDog,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isDog = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Gato'),
          trailing: Checkbox(
            value: _isCat,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCat = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Conejo'),
          trailing: Checkbox(
            value: _isRabbit,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isRabbit = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Hamster'),
          trailing: Checkbox(
            value: _isHamster,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isHamster = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Hurón'),
          trailing: Checkbox(
            value: _isFerret,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isFerret = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Cobaya'),
          trailing: Checkbox(
            value: _isGuineaPig,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isGuineaPig = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Chinchilla'),
          trailing: Checkbox(
            value: _isChinchilla,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isChinchilla = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Pájaro'),
          trailing: Checkbox(
            value: _isBird,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isBird = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Pez'),
          trailing: Checkbox(
            value: _isFish,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isFish = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Tortuga'),
          trailing: Checkbox(
            value: _isTortoise,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isTortoise = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Erizo'),
          trailing: Checkbox(
            value: _isHedgehog,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isHedgehog = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Caballo'),
          trailing: Checkbox(
            value: _isHorse,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isHorse = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Otro'),
          trailing: Checkbox(
            value: _isOther,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isOther = value!;
              });
            },
          )),
    ]));
  }

  getFilterGender() {
    return Column(children: <Widget>[
      ListTile(
          title: const Text('Macho'),
          trailing: Checkbox(
            value: _isMale,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMale = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Hembra'),
          trailing: Checkbox(
            value: _isFemale,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isFemale = value!;
              });
            },
          )),
    ]);
  }

  getFilterProvince() {
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      ListTile(
          title: const Text('A Coruña'),
          trailing: Checkbox(
            value: _isACoruna,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isACoruna = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Alava'),
          trailing: Checkbox(
            value: _isAlava,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAlava = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Albacete'),
          trailing: Checkbox(
            value: _isAlbacete,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAlbacete = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Alicante'),
          trailing: Checkbox(
            value: _isAlicante,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAlicante = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Almería'),
          trailing: Checkbox(
            value: _isAlmeria,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAlmeria = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Asturias'),
          trailing: Checkbox(
            value: _isAsturias,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAsturias = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Avila'),
          trailing: Checkbox(
            value: _isAvila,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isAvila = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Badajoz'),
          trailing: Checkbox(
            value: _isBadajoz,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isBadajoz = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Barcelona'),
          trailing: Checkbox(
            value: _isBarcelona,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isBarcelona = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Burgos'),
          trailing: Checkbox(
            value: _isBurgos,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isBurgos = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Cáceres'),
          trailing: Checkbox(
            value: _isCaceres,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCaceres = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Cádiz'),
          trailing: Checkbox(
            value: _isCadiz,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCadiz = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Cantabria'),
          trailing: Checkbox(
            value: _isCantabria,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCantabria = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Castellón'),
          trailing: Checkbox(
            value: _isCastellon,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCastellon = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Ceuta'),
          trailing: Checkbox(
            value: _isCeuta,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCeuta = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Ciudad Real'),
          trailing: Checkbox(
            value: _isCiudadReal,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCiudadReal = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Córdoba'),
          trailing: Checkbox(
            value: _isCordoba,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCordoba = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Cuenca'),
          trailing: Checkbox(
            value: _isCuenca,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isCuenca = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Formentera'),
          trailing: Checkbox(
            value: _isFormentera,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isFormentera = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Girona'),
          trailing: Checkbox(
            value: _isGirona,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isGirona = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Granada'),
          trailing: Checkbox(
            value: _isGranada,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isGranada = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Guadalajara'),
          trailing: Checkbox(
            value: _isGuadalajara,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isGuadalajara = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Guipuzcoa'),
          trailing: Checkbox(
            value: _isGuipuzcoa,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isGuipuzcoa = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Huelva'),
          trailing: Checkbox(
            value: _isHuelva,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isHuelva = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Huesca'),
          trailing: Checkbox(
            value: _isHuesca,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isHuesca = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Ibiza'),
          trailing: Checkbox(
            value: _isIbiza,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isIbiza = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Jaén'),
          trailing: Checkbox(
            value: _isJaen,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isJaen = value!;
              });
            },
          )),
      ListTile(
          title: const Text('La Rioja'),
          trailing: Checkbox(
            value: _isLaRioja,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isLaRioja = value!;
              });
            },
          )),
      ListTile(
          title: const Text('León'),
          trailing: Checkbox(
            value: _isLeon,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isLeon = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Lérida'),
          trailing: Checkbox(
            value: _isLerida,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isLerida = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Lugo'),
          trailing: Checkbox(
            value: _isLugo,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isLugo = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Madrid'),
          trailing: Checkbox(
            value: _isMadrid,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMadrid = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Málaga'),
          trailing: Checkbox(
            value: _isMalaga,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMalaga = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Mallorca'),
          trailing: Checkbox(
            value: _isMallorca,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMallorca = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Menorca'),
          trailing: Checkbox(
            value: _isMenorca,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMenorca = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Murcia'),
          trailing: Checkbox(
            value: _isMurcia,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isMurcia = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Navarra'),
          trailing: Checkbox(
            value: _isNavarra,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isNavarra = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Orense'),
          trailing: Checkbox(
            value: _isOrense,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isOrense = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Palencia'),
          trailing: Checkbox(
            value: _isPalencia,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isPalencia = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Pontevedra'),
          trailing: Checkbox(
            value: _isPontevedra,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isPontevedra = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Salamanca'),
          trailing: Checkbox(
            value: _isSalamanca,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isSalamanca = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Segovia'),
          trailing: Checkbox(
            value: _isSegovia,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isSegovia = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Sevilla'),
          trailing: Checkbox(
            value: _isSevilla,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isSevilla = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Soria'),
          trailing: Checkbox(
            value: _isSoria,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isSoria = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Tarragona'),
          trailing: Checkbox(
            value: _isTarragona,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isTarragona = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Teruel'),
          trailing: Checkbox(
            value: _isTeruel,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isTeruel = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Toledo'),
          trailing: Checkbox(
            value: _isToledo,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isToledo = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Valencia'),
          trailing: Checkbox(
            value: _isValencia,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isValencia = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Valladolid'),
          trailing: Checkbox(
            value: _isValladolid,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isValladolid = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Vizcaya'),
          trailing: Checkbox(
            value: _isVizcaya,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isVizcaya = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Zamora'),
          trailing: Checkbox(
            value: _isZamora,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isZamora = value!;
              });
            },
          )),
      ListTile(
          title: const Text('Zaragoza'),
          trailing: Checkbox(
            value: _isZaragoza,
            onChanged: (bool? value) {
              _overlay?.setState(() {
                _isZaragoza = value!;
              });
            },
          )),
    ]));
  }

  buildAdoptionsResults() {
    Future<QuerySnapshot> adoptions =
        adoptionsRef.orderBy('timeStamp', descending: true).get();

    setState(() {
      searchResultsFuture = adoptions;
    });

    checkFilter(List<bool> auxlist) {
      var filter = false;
      for (var i = 0; i < auxlist.length; i++) {
        if (auxlist[i] == true) {
          filter = true;
        }
      }
      return filter;
    }

    List<AdoptionResult> addResult(
        List<AdoptionResult> auxResults, List<AdoptionResult> searchResults) {
      for (var j = 0; j < auxResults.length; j++) {
        searchResults.add(auxResults[j]);
      }

      return searchResults;
    }

    List<AdoptionResult> compareFilterType(List<bool> boolList,
        List<AdoptionResult> searchResults, List<AdoptionResult> auxResults) {
      for (var k = 0; k < boolList.length; k++) {
        if (boolList[k] == true) {
          for (var l = 0; l < searchResults.length; l++) {
            if (searchResults[l].adoption.type == typeListAnimals[k]) {
              auxResults.add(searchResults[l]);
            }
          }
        }
      }
      return auxResults;
    }

    List<AdoptionResult> compareFilterGender(List<bool> boolList,
        List<AdoptionResult> searchResults, List<AdoptionResult> auxResults) {
      for (var m = 0; m < boolList.length; m++) {
        if (boolList[m] == true) {
          for (var n = 0; n < searchResults.length; n++) {
            if (searchResults[n].adoption.gender == genderListAnimals[m]) {
              auxResults.add(searchResults[n]);
            }
          }
        }
      }
      return auxResults;
    }

    List<AdoptionResult> compareFilterProvince(List<bool> boolList,
        List<AdoptionResult> searchResults, List<AdoptionResult> auxResults) {
      for (var o = 0; o < boolList.length; o++) {
        if (boolList[o] == true) {
          for (var p = 0; p < searchResults.length; p++) {
            if (searchResults[p].adoption.province == provinceListAnimals[o]) {
              auxResults.add(searchResults[p]);
            }
          }
        }
      }
      return auxResults;
    }

    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<AdoptionResult> searchResults = [];
        List<AdoptionResult> searchAuxResults = [];
        List<AdoptionResult> typeResults = [];
        List<AdoptionResult> genderResults = [];
        List<AdoptionResult> provinceResults = [];
        List<bool> boolListAnimals = [];
        List<bool> boolListGender = [];
        List<bool> boolListProvince = [];

        //add types filter
        boolListAnimals.add(_isDog);
        boolListAnimals.add(_isCat);
        boolListAnimals.add(_isRabbit);
        boolListAnimals.add(_isHamster);
        boolListAnimals.add(_isFerret);
        boolListAnimals.add(_isGuineaPig);
        boolListAnimals.add(_isChinchilla);
        boolListAnimals.add(_isBird);
        boolListAnimals.add(_isFish);
        boolListAnimals.add(_isTortoise);
        boolListAnimals.add(_isHedgehog);
        boolListAnimals.add(_isHorse);
        boolListAnimals.add(_isOther);

        //add gender filter
        boolListGender.add(_isMale);
        boolListGender.add(_isFemale);

        //add provinces filter
        boolListProvince.add(_isACoruna);
        boolListProvince.add(_isAlava);
        boolListProvince.add(_isAlbacete);
        boolListProvince.add(_isAlicante);
        boolListProvince.add(_isAlmeria);
        boolListProvince.add(_isAsturias);
        boolListProvince.add(_isAvila);
        boolListProvince.add(_isBadajoz);
        boolListProvince.add(_isBarcelona);
        boolListProvince.add(_isBurgos);
        boolListProvince.add(_isCaceres);
        boolListProvince.add(_isCadiz);
        boolListProvince.add(_isCantabria);
        boolListProvince.add(_isCastellon);
        boolListProvince.add(_isCeuta);
        boolListProvince.add(_isCiudadReal);
        boolListProvince.add(_isCordoba);
        boolListProvince.add(_isCuenca);
        boolListProvince.add(_isFormentera);
        boolListProvince.add(_isGirona);
        boolListProvince.add(_isGranada);
        boolListProvince.add(_isGuadalajara);
        boolListProvince.add(_isGuipuzcoa);
        boolListProvince.add(_isHuelva);
        boolListProvince.add(_isHuesca);
        boolListProvince.add(_isIbiza);
        boolListProvince.add(_isJaen);
        boolListProvince.add(_isLaRioja);
        boolListProvince.add(_isLeon);
        boolListProvince.add(_isLerida);
        boolListProvince.add(_isLugo);
        boolListProvince.add(_isMadrid);
        boolListProvince.add(_isMalaga);
        boolListProvince.add(_isMallorca);
        boolListProvince.add(_isMenorca);
        boolListProvince.add(_isMurcia);
        boolListProvince.add(_isNavarra);
        boolListProvince.add(_isOrense);
        boolListProvince.add(_isPalencia);
        boolListProvince.add(_isPontevedra);
        boolListProvince.add(_isSalamanca);
        boolListProvince.add(_isSegovia);
        boolListProvince.add(_isSevilla);
        boolListProvince.add(_isSoria);
        boolListProvince.add(_isTarragona);
        boolListProvince.add(_isTeruel);
        boolListProvince.add(_isToledo);
        boolListProvince.add(_isValencia);
        boolListProvince.add(_isValladolid);
        boolListProvince.add(_isVizcaya);
        boolListProvince.add(_isZamora);
        boolListProvince.add(_isZaragoza);

        for (var doc in snapshot.data!.docs) {
          Adoption adoption = Adoption.fromDocument(doc);
          AdoptionResult searchResult = AdoptionResult(adoption);
          searchAuxResults.add(searchResult);
        }

        //See if there are filters
        filterAnimals = checkFilter(boolListAnimals);
        filterGender = checkFilter(boolListGender);
        filterProvince = checkFilter(boolListProvince);

        //Compare differents filtters combinations
        //if all filters are false
        if (filterAnimals == false &&
            filterGender == false &&
            filterProvince == false) {
          searchResults = addResult(searchAuxResults, searchResults);

          //if all filters are true
        } else if (filterAnimals == true &&
            filterGender == true &&
            filterProvince == true) {
          typeResults =
              compareFilterType(boolListAnimals, searchAuxResults, typeResults);

          genderResults =
              compareFilterGender(boolListGender, typeResults, genderResults);

          provinceResults = compareFilterProvince(
              boolListProvince, genderResults, provinceResults);

          searchResults = addResult(provinceResults, searchResults);

          //if type filter is true
        } else if (filterAnimals == true) {
          if (filterGender == true) {
            typeResults = compareFilterType(
                boolListAnimals, searchAuxResults, typeResults);

            genderResults =
                compareFilterGender(boolListGender, typeResults, genderResults);

            searchResults = addResult(genderResults, searchResults);
          } else if (filterProvince == true) {
            typeResults = compareFilterType(
                boolListAnimals, searchAuxResults, typeResults);

            provinceResults = compareFilterProvince(
                boolListProvince, typeResults, provinceResults);

            searchResults = addResult(provinceResults, searchResults);
          } else {
            typeResults = compareFilterType(
                boolListAnimals, searchAuxResults, typeResults);

            searchResults = addResult(typeResults, searchResults);
          }
        } else if (filterGender == true) {
          if (filterProvince == true) {
            genderResults = compareFilterGender(
                boolListGender, searchAuxResults, genderResults);

            provinceResults = compareFilterProvince(
                boolListProvince, genderResults, provinceResults);
            searchResults = addResult(provinceResults, searchResults);
          } else {
            genderResults = compareFilterGender(
                boolListGender, searchAuxResults, genderResults);

            searchResults = addResult(genderResults, searchResults);
          }
        } else if (filterProvince == true) {
          provinceResults = compareFilterProvince(
              boolListProvince, searchAuxResults, provinceResults);
          searchResults = addResult(provinceResults, searchResults);
        }

        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 40,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        _overlayEntry = _createOverlayEntry();
                        _overlay?.insert(_overlayEntry!);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 81, 212, 212),
                      ),
                      child: const Text(
                        'Filtrar',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (searchResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 250.0),
                  child: AutoSizeText("No se han encontrado resultados"),
                ),
              GridView.count(
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                crossAxisCount: 2,
                childAspectRatio: (200 / 450),
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                shrinkWrap: true,
                children: searchResults,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      drawer: Drawer(child: construirListView(context, currentUser)),
      body: buildAdoptionsResults(),
    );
  }
}

class AdoptionResult extends StatefulWidget {
  final Adoption adoption;

  const AdoptionResult(this.adoption);

  @override
  State<AdoptionResult> createState() => _AdoptionResultState();
}

class _AdoptionResultState extends State<AdoptionResult> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewAdoption(
                        adoptionId: widget.adoption.id,
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6.0),
                topRight: Radius.circular(6.0),
              ),
              child: Image.network(
                widget.adoption.mediaUrl,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AutoSizeText(
                    widget.adoption.name +
                        "\n\n" +
                        "Sexo: " +
                        widget.adoption.gender +
                        "\n\nEdad: " +
                        widget.adoption.age.toString() +
                        " años",
                    style: const TextStyle(fontSize: 15.0),
                  ),
                ),
                if (widget.adoption.type == "Perro")
                  Image.asset(
                    'assets/images/dog.png',
                    scale: 8,
                  ),
                if (widget.adoption.type == "Gato")
                  Image.asset(
                    'assets/images/cat.png',
                    scale: 5,
                  ),
                if (widget.adoption.type == "Conejo")
                  Image.asset(
                    'assets/images/rabbit.png',
                    scale: 10,
                  ),
                if (widget.adoption.type == "Hamster")
                  Image.asset(
                    'assets/images/hamster.png',
                    scale: 7,
                  ),
                if (widget.adoption.type == "Hurón")
                  Image.asset(
                    'assets/images/ferret.png',
                    scale: 6,
                  ),
                if (widget.adoption.type == "Cobaya")
                  Image.asset(
                    'assets/images/guineaPig.png',
                    scale: 6,
                  ),
                if (widget.adoption.type == "Chinchilla")
                  Image.asset(
                    'assets/images/chinchilla.png',
                    scale: 18,
                  ),
                if (widget.adoption.type == "Pájaro")
                  Image.asset(
                    'assets/images/bird.png',
                    scale: 40,
                  ),
                if (widget.adoption.type == "Pez")
                  Image.asset(
                    'assets/images/fish.png',
                    scale: 20,
                  ),
                if (widget.adoption.type == "Tortuga")
                  Image.asset(
                    'assets/images/tortoise.png',
                    scale: 6,
                  ),
                if (widget.adoption.type == "Erizo")
                  Image.asset(
                    'assets/images/hedgehog.png',
                    scale: 6,
                  ),
                if (widget.adoption.type == "Caballo")
                  Image.asset(
                    'assets/images/horse.png',
                    scale: 10,
                  ),
                if (widget.adoption.type == "Otro") const Icon(Icons.pets)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
