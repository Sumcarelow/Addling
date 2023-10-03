import 'package:adlinc/pages/address_search/places.dart';
import 'package:flutter/material.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch({ this.sessionToken}) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  late PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    Suggestion temp = Suggestion('', '');
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, temp);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Placeholder();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
        padding: EdgeInsets.all(16.0),
        child: Text('Enter your address'),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.location_on, color: Colors.grey,),
          title:
          Text((snapshot.data![index]).description),
          onTap: () {
            close(context, snapshot.data![index] as Suggestion);
          },
        ),
        itemCount: snapshot.data?.length,
      )
          : Container(child: Text('Loading...')),
    );
  }
}