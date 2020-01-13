import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(new MyApp());

// 这个 application 继承自 StatelessWidget ，这将会使 application 本身也变成一个 widget
// 在 Flutter 中，大多数东西都是 widget ，包括对齐（alignment）、填充（padding）和布局（layout）

class MyApp extends StatelessWidget {
  // widget 的主要工作是`提供一个 build() 方法来描述如何根据其他较低级别的 widget 来显示自己 `
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name 生成器',
      // Scaffold 是 Material library 中提供的一个 widget ，提供了默认的导航栏、标题和包含主屏幕 widget 树的 body 属性
      home: new RandomWords(),
      theme: new ThemeData(
        primaryColor: Colors.greenAccent,
      ),
    );
  }
}

/*
* Stateless widgets 是不可变的，这意味着它们的属性不能改变 - 所有值都是最终的
* Stateful widgets 持有的状态可能在 widget 生命周期中发生变化，实现一个 Stateful widget 至少需要两个类：
* 1. 一个 StatefulWidget 类
* 2. 一个 State 类；StatefulWidget 类本身是不可变的，但是 State 类在 widget 生命周期中始终存在
* */

class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  // 数组保存建议的 wordPair
  final _suggestions = <WordPair>[];

  // 增大字体大小
  final _biggerFont = const TextStyle(fontSize: 18.0);

  // Set 集合存储用户喜欢（收藏）的 wordPair ，在这里，Set 比 List 更合适，因为 Set 不允许重复的值
  final _saved = new Set<WordPair>();

  @override
  Widget build(BuildContext context) {
    // 使用 _buildSuggestions() 方法而不是直接调用单词生成库
    /*
    final wordPair = new WordPair.random();
    return new Text(wordPair.asPascalCase);
     */
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Startup Name 生成器'),
        actions: <Widget>[
          // 添加一个列表图标。当用户点击列表图标时，包含收藏夹的新路由页面入栈显示
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  // 对于每一个 wordPair ，_buildSuggestions 都会调用一次 _buildRow
  // 这个函数在 ListTitle 中显示每个新词对
  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // 对于每个建议的 wordPair 都会调用一次 itemBuilder ，然后将 wordPair 添加到 ListTitle 行中
        // 在偶数行，该函数会为 wordPair 添加一个 ListTitle row
        // 在奇数行，该函数会添加一个分割线 widget ，来分割相邻的 wordPair
        // 注意，在小屏幕上，分割线看起来可能比较吃力
        itemBuilder: (context, i) {
          // itemBuilder 值是一个匿名回调函数，接收两个参数 `BuildContext` 和行迭代器 `i` 。
          // 在每一列之前，添加一个 1 像素高的分割线 widget
          if (i.isOdd) return new Divider();

          // 语法 `i ~/ 2` 表示 i 除以 2 ，但返回值是整形（向下取整），比如 i 为 1，2，3，4，5 时
          // 结果为 0，1，1，2，2，这可以计算出 ListView 中减去分割线后的实际 wordPair 数量
          final index = i ~/ 2;
          // 如果是建议列表中最后一个 wordPair
          if (index >= _suggestions.length) {
            // ... 接着在再生成 10 个 wordPair ，然后添加到建议列表
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    // 检查确保 wordPair 还没有添加到收藏夹中
    final alreadySaved = _saved.contains(pair);

    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      // 添加♥型按钮
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        // 函数调用 setState() 通知框架状态已经改变 —— 调用 setState() 会为 State 对象触发 build() 方法，从而导致对UI的更新
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  // 当用户点击导航栏中的列表图标时，建立一个路由并将其推入到导航管理器栈中 —— 此操作会切换页面以显示新路由
  void _pushSaved() {
    // 新页面的内容在 MaterialPageRoute 的 builder 属性中构建， builder 是一个匿名函数
    // 添加 Navigator.push 调用，这会使路由入栈
    Navigator.of(context).push(
      // 添加 MaterialPageRoute 以及其 builder —— builder 返回一个 Scaffold ，其中包含名为 Saved Suggestions 的新路由的应用栏
      // 新路由的 body 由包含 ListTiles 行的 ListView 组成；每行之间通过一个分隔线分隔
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }
}