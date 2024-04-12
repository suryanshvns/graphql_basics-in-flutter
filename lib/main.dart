import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final HttpLink httpLink = HttpLink(
    'https://countries.trevorblades.com/',
  );

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

    return GraphQLProvider(
      client: client,
      child: CacheProvider(child: MaterialApp(home: CountryList(),debugShowCheckedModeBanner: false,)),
    );
  }
}

class CountryList extends StatelessWidget {

 String _getLanguages(Map<String, dynamic> country) {
  final List<dynamic>? languages = country['languages'];
  if (languages == null) {
    return '';
  }
  return languages.map((lang) => lang['name']).join(', ');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries Name'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql('''
            query {
              countries {
                name
                code
                capital
                emoji
                currencies
                languages{
                  name
                }
              }
            }
          '''),
        ),
        builder: (QueryResult result, {Future<QueryResult> Function(FetchMoreOptions)? fetchMore, Future<QueryResult?> Function()? refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

        final List<dynamic>? countries = result.data?['countries'];
          return ListView.builder(
            itemCount: countries?.length ?? 0,
            itemBuilder: (context, index) {
              final country = countries?[index];
              if (country == null) {
                return const SizedBox(); // or any other placeholder widget
              }
              return ListTile(
                title: Text('${country['name']} (${country['code']}) (${country['currencies']})'),
                subtitle: Column(
                  children: [
                    Text('Capital: ${country['capital'] ?? ''}'),
                    Text('Languages: ${_getLanguages(country)}'),
                  ],
                ),
                trailing: Text(country['emoji'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
