import 'dart:html';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:google_fonts/google_fonts.dart';
import 'package:microlab/Chart/ZoneData.dart';
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;

num? currentVal = 0;
num? currentValx = 0;

class DeveloperChartCompareZones extends StatelessWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
  final List<ZoneData> tData;
  final List<ZoneData> lData;
  final List<ZoneData> nData;
  final String chartTitle;

  var axis = const charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
    labelStyle: charts.TextStyleSpec(
        fontSize: 10,
        color: charts.MaterialPalette
            .white), //chnage white color as per your requirement.
  ));

  DeveloperChartCompareZones(
      {required this.tData,
      required this.lData,
      required this.chartTitle,
      required this.nData});

  @override
  Widget build(BuildContext context) {
    final blue = charts.MaterialPalette.blue.makeShades(2);
    final red = charts.MaterialPalette.red.makeShades(2);
    final green = charts.MaterialPalette.green.makeShades(2);
    List<charts.Series<ZoneData, num>> seriesList = [
      charts.Series(
        id: "Temp",
        data: tData,
        colorFn: (ZoneData series, _) => blue[0],
        domainFn: (ZoneData series, _) => series.time,
        measureFn: (ZoneData series, _) => series.value,
      ),
      charts.Series(
        id: "Light",
        data: lData,
        colorFn: (ZoneData series, _) => red[0],
        domainFn: (ZoneData series, _) => series.time,
        measureFn: (ZoneData series, _) => series.value,
      ),
      charts.Series(
        id: "Noise",
        data: nData,
        colorFn: (ZoneData series, _) => green[0],
        domainFn: (ZoneData series, _) => series.time,
        measureFn: (ZoneData series, _) => series.value,
      ),
    ];

    return Container(
      height: (MediaQuery.of(context).size.height) / 4,
      width: (MediaQuery.of(context).size.width) / 2.2,
      padding: const EdgeInsets.all(5),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Text(
                chartTitle,
                style: GoogleFonts.montserrat(),
              ),
              Expanded(
                child: charts.LineChart(
                  seriesList,
                  animate: false,
                  primaryMeasureAxis: axis,
                  secondaryMeasureAxis: axis,
                  defaultRenderer: charts.LineRendererConfig(
                    includeArea: false,
                    includeLine: true,
                  ),
                  behaviors: [
                    charts.PanAndZoomBehavior(),
                    charts.SeriesLegend(
                      position: charts.BehaviorPosition.top,
                      horizontalFirst: false,
                      cellPadding:
                          EdgeInsets.only(left: 80, top: 10, bottom: 4.0),
                    ),
                    charts.SelectNearest(
                        eventTrigger: charts.SelectionTrigger.tap),
                    charts.LinePointHighlighter(
                      symbolRenderer: CustomCircleSymbolRenderer(),
                    ),
                  ],
                  selectionModels: [
                    charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: (SelectionModel model) {
                          currentValx = model.selectedSeries[0].domainFn(model.selectedDatum[0].index);
                      currentVal = model.selectedSeries[0]
                          .measureFn(model.selectedDatum[0].index);
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      Color? fillColor,
      FillPatternType? fillPattern,
      Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 75,
            bounds.height + 10),
        fill: Color.fromHex(code: "#D3D3D3"));
    var textStyle = style.TextStyle();
    textStyle.color = Color.fromHex(code: "#000000");
    textStyle.fontSize = 15;
    canvas.drawText(
        TextElement.TextElement("$currentVal / $currentValx", style: textStyle),
        (bounds.left).round(),
        (bounds.top - 28).round());
  }
}
