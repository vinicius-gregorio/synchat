import 'package:flutter/material.dart';
import 'package:synchat/pages/chat_page.dart';
import 'package:synchat/pages/profile_page.dart';
import 'package:synchat/pages/recent_conversations_page.dart';
import 'package:synchat/pages/search_page.dart';
import '../models/colors.dart' as color;

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  double deviceHeight, deviceWidth;
  int selectedIndex = 0;
  TabController _tabController;

  _HomepageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            iconSize: 30,
            color: color.secundaryColor,
            onPressed: () {},
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 30,
              color: color.secundaryColor,
              onPressed: () {},
            ),
          ],
          title: Text(
            "Synchat",
            style: TextStyle(color: color.secundaryColor),
          ),
          centerTitle: true,
          bottom: TabBar(
              unselectedLabelColor: color.secundaryColor,
              indicatorColor: color.thirdColor,
              labelColor: color.thirdColor,
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.people_outline,
                    size: 25,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 25,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.person_outline,
                    size: 25,
                  ),
                ),
              ]),
        ),
        body: _tabBarPages(),
        backgroundColor: Colors.white);
  }

  Widget _tabBarPages() {
    return TabBarView(controller: _tabController, children: <Widget>[
      // ChatPage(deviceHeight, deviceWidth),
      SearchPage(deviceHeight, deviceWidth),
      RecentConversationsPage(deviceHeight, deviceWidth),
      ProfilePage(deviceHeight, deviceWidth),
    ]);
  }
}
