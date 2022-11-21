import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsGraphQL = """
    query products {
      products(first: 4,channel: "default-channel") {
        edges {
          node {
            id
            name
            description
            thumbnail {
              url
            }
          }
        }
      }
  }
  """;

void main() {
  final HttpLink httpLink = HttpLink("https://demo.saleor.io/graphql/");
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(
          store: InMemoryStore(),
        )),
  );

// provides client to the widget tree
  var app = GraphQLProvider(child: const MyApp(), client: client);

  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo GraphQL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
          options: QueryOptions(document: gql(productsGraphQL)),
          builder: (QueryResult result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final productList = result.data?['products']['edges'];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Products",
                      style: Theme.of(context).textTheme.headline5),
                ),
                Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2.0,
                          crossAxisSpacing: 2.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: productList.length,
                        itemBuilder: (_, index) {
                          var product = productList[index]['node'];
                          return Column(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(2.0),
                                  width: 180,
                                  height: 170,
                                  child: Image.network(
                                      product['thumbnail']['url'])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              const Text('\$4.50')
                            ],
                          );
                        }))
              ],
            );
          }),
    );
  }
}
