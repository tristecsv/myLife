// // Gráfica mensual simple usando fl_chart: barras diarias con in/out (dos series)
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class MonthlyIncomeExpenseChart extends StatelessWidget {
//   final Map<int, Map<String, double>> dayInOut; // day -> {'in':x, 'out':y}
//   final int month;
//   final int year;

//   const MonthlyIncomeExpenseChart({
//     super.key,
//     required this.dayInOut,
//     required this.month,
//     required this.year,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final daysInMonth = DateUtils.getDaysInMonth(year, month);
//     final maxVal = dayInOut.values.fold<double>(0.0, (p, e) {
//       final d = (e['in'] ?? 0) + (e['out'] ?? 0);
//       return d > p ? d : p;
//     });

//     return SizedBox(
//       height: 200,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceBetween,
//           maxY: (maxVal * 1.2).clamp(10.0, double.infinity),
//           barGroups: List.generate(daysInMonth, (i) {
//             final day = i + 1;
//             final d = dayInOut[day] ?? {'in': 0.0, 'out': 0.0};
//             // We'll stack: ingresos (positive, green) and gastos (negative shown as positive but colored red)
//             final inVal = d['in'] ?? 0.0;
//             final outVal = d['out'] ?? 0.0;
//             return BarChartGroupData(
//               x: day,
//               barRods: [
//                 BarChartRodData(
//                   toY: inVal,
//                   color: Theme.of(context).colorScheme.primary,
//                   width: 6,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//                 BarChartRodData(
//                   toY: outVal,
//                   color: Colors.redAccent,
//                   width: 6,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ],
//               barsSpace: 2,
//             );
//           }),
//           titlesData: FlTitlesData(
//             leftTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
//             bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (v, meta) {
//                       final day = v.toInt();
//                       final text = (day % 5 == 0 ||
//                               day == 1 ||
//                               day == DateTime.now().day)
//                           ? day.toString()
//                           : '';
//                       return Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child:
//                               Text(text, style: const TextStyle(fontSize: 10)));
//                     },
//                     reservedSize: 22)),
//             topTitles:
//                 const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles:
//                 const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           gridData: const FlGridData(show: true, drawHorizontalLine: true),
//           borderData: FlBorderData(show: false),
//         ),
//       ),
//     );
//   }
// }
