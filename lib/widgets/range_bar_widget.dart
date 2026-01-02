import 'package:flutter/material.dart';
import '../models/test_metadata.dart';
import '../models/range.dart';

class RangeBarWidget extends StatelessWidget {
  final TestMetadata testMetadata;
  final double inputValue;

  const RangeBarWidget({
    super.key,
    required this.testMetadata,
    required this.inputValue,
  });

  @override
  Widget build(BuildContext context) {
    if (testMetadata.ranges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                'No ranges available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final minValue = testMetadata.minimumValue;
    final maxValue = testMetadata.maximumValue;
    final valueRange = maxValue - minValue;
    
    if (valueRange <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Invalid range: min and max values are equal',
            style: TextStyle(color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentRange = testMetadata.getRangeForValue(inputValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth.clamp(0.0, double.infinity);
            if (barWidth <= 0) {
              return const SizedBox.shrink();
            }
            
            double? indicatorPosition;
            
            if (inputValue.isFinite && !inputValue.isNaN) {
              if (inputValue >= minValue && inputValue <= maxValue) {
                final normalizedValue = ((inputValue - minValue) / valueRange).clamp(0.0, 1.0);
                indicatorPosition = (normalizedValue * barWidth).clamp(0.0, barWidth - 3);
              } else if (inputValue < minValue) {
                indicatorPosition = 0.0;
              } else if (inputValue > maxValue) {
                indicatorPosition = (barWidth - 3).clamp(0.0, barWidth);
              }
            }

            return Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: testMetadata.ranges.map((range) {
                      final rangeSize = range.max - range.min;
                      final flexValue = (rangeSize * 10000).round().clamp(1, 100000);
                      
                      return Expanded(
                        flex: flexValue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(range.colorValue),
                            borderRadius: _getBorderRadiusForRange(
                              range,
                              testMetadata.ranges,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (indicatorPosition != null)
                    Positioned(
                      left: indicatorPosition,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -8),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 3.5,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.speed,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Value',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              inputValue.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            if (inputValue < minValue || inputValue > maxValue) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                inputValue < minValue ? 'Below range' : 'Above range',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (currentRange != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(currentRange.colorValue),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(currentRange.colorValue).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentRange.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else if (inputValue >= minValue && inputValue <= maxValue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No range',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.legend_toggle,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Range Legend',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: testMetadata.ranges.map((range) {
                final isActive = currentRange != null &&
                    currentRange.min == range.min &&
                    currentRange.max == range.max;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Color(range.colorValue)
                        : Color(range.colorValue).withOpacity(0.15),
                    border: Border.all(
                      color: isActive
                          ? Colors.black
                          : Color(range.colorValue).withOpacity(0.5),
                      width: isActive ? 2.5 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Color(range.colorValue).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Color(range.colorValue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${range.min.toStringAsFixed(0)} - ${range.max.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : Colors.grey.shade900,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            range.label,
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? Colors.white : Colors.grey.shade700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  BorderRadius _getBorderRadiusForRange(
    Range range,
    List<Range> allRanges,
  ) {
    final isFirst = range == allRanges.first;
    final isLast = range == allRanges.last;

    if (isFirst && isLast) {
      return BorderRadius.circular(6);
    } else if (isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      );
    } else if (isLast) {
      return const BorderRadius.only(
        topRight: Radius.circular(6),
        bottomRight: Radius.circular(6),
      );
    }
    return BorderRadius.zero;
  }
}

