import 'package:flutter/material.dart';

/*class ComponentLibraryApp {
  static Widget buildApp() {
    return MaterialApp(
      title: 'MD3 Component Library',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue),
      home: const ComponentLibrary(),
    );
  }
}

void main() {
  runApp(ComponentLibraryApp.buildApp());
}
*/
class ComponentLibrary extends StatefulWidget {
  const ComponentLibrary({super.key});

  @override
  State<ComponentLibrary> createState() => _ComponentLibraryState();
}

class _ComponentLibraryState extends State<ComponentLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('MD3 Component Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: () {
              // Placeholder action, as theme control is removed
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buttons'),
            Tab(text: 'Cards'),
            Tab(text: 'Dialogs'),
            Tab(text: 'Lists'),
            Tab(text: 'Sliders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ButtonsTab(),
          CardsTab(),
          DialogsTab(),
          ListsTab(),
          SlidersTab(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab1',
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'fab2',
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
            _tabController.animateTo(index);
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.smart_button),
            label: 'Buttons',
          ),
          NavigationDestination(
            icon: Icon(Icons.style),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Dialogs',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Sliders',
          ),
        ],
      ),
    );
  }
}

class ButtonsTab extends StatelessWidget {
  const ButtonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
          FilledButton(onPressed: () {}, child: const Text('Filled')),
          FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
          OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
          TextButton(onPressed: () {}, child: const Text('Text')),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          const Chip(label: Text('Chip')),
          ActionChip(
            label: const Text('Action Chip'),
            onPressed: () {},
          ),
          const InputChip(label: Text('Input Chip')),
          const ChoiceChip(label: Text('Choice Chip'), selected: true),
          FilterChip(
              label: const Text('Filter Chip'),
              selected: true,
              onSelected: (bool? value) {}),
        ],
      ),
    );
  }
}

class CardsTab extends StatelessWidget {
  const CardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Card Title', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Card Content'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Elevated Card Title', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Elevated Card Content'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Outlined Card Title', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Outlined Card Content'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DialogsTab extends StatelessWidget {
  const DialogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('Show Dialog'),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('AlertDialog Title'),
                content: const Text('AlertDialog description'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ListsTab extends StatelessWidget {
  const ListsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Item 1'),
          subtitle: Text('Subtitle 1'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.email),
          title: Text('Item 2'),
          subtitle: Text('Subtitle 2'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Item 3'),
          subtitle: Text('Subtitle 3'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }
}

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      child: child,
    );
  }
}

class OutlinedCard extends StatelessWidget {
  const OutlinedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: child,
    );
  }
}

class SlidersTab extends StatefulWidget {
  const SlidersTab({super.key});

  @override
  State<SlidersTab> createState() => _SlidersTabState();
}

class _SlidersTabState extends State<SlidersTab> {
  double _sliderValue = 0.5;
  double _rangeSliderStart = 0.2;
  double _rangeSliderEnd = 0.8;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Slider Value: ${_sliderValue.toStringAsFixed(2)}'),
          Slider(
            value: _sliderValue,
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
              'Range Slider Start: ${_rangeSliderStart.toStringAsFixed(2)}, End: ${_rangeSliderEnd.toStringAsFixed(2)}'),
          RangeSlider(
            values: RangeValues(_rangeSliderStart, _rangeSliderEnd),
            onChanged: (RangeValues values) {
              setState(() {
                _rangeSliderStart = values.start;
                _rangeSliderEnd = values.end;
              });
            },
          ),
          const SizedBox(height: 20),
          const Text('Adaptive Slider'),
          const SizedBox(height: 10),
          Slider.adaptive(
            value: _sliderValue,
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
        ],
      ),
    );
  }
}