import 'package:SIMANIS_V1/providers/news.provider.dart';
import 'package:flutter/material.dart';
import 'package:SIMANIS_V1/components/news.dart' as news_component;
import 'package:provider/provider.dart';
import 'search_page.dart';
import 'package:SIMANIS_V1/helpers/url_launcher.dart';

class BeritaSection extends StatefulWidget {
  @override
  _BeritaSectionState createState() => _BeritaSectionState();
}

class _BeritaSectionState extends State<BeritaSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).getTopNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (BuildContext context, news, Widget? child) {
        return SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Berita",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 170,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<NewsProvider>(
                      context,
                      listen: false,
                    ).getTopNews();
                  },
                  child:
                      news.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: news.resNews?.articles?.length ?? 0,
                            // ...existing code...
                            itemBuilder: (context, index) {
                              final article = news.resNews!.articles![index];
                              final url = article.url ?? '';
                              return InkWell(
                                onTap: () {
                                  if (url.isNotEmpty) {
                                    launchURL(
                                      context,
                                      url,
                                    ); // pastikan sudah import url_launcher.dart helper
                                  }else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('URL tidak tersedia'),
                                      ),
                                    );
                                  }
                                  print('URL yang akan dibuka: $url');
                                },
                                child: news_component.News(
                                  title: article.title ?? '',
                                  image: article.urlToImage ?? '',
                                ),
                              );
                            },
                            // ...existing code...
                            separatorBuilder:
                                (context, index) => SizedBox(width: 8),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
