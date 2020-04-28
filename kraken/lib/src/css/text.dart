/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

<<<<<<< HEAD
const double DEFAULT_FONT_SIZE = 14.0;
const double DEFAULT_LETTER_SPACING = 0.0;
const double DEFAULT_WORD_SPACING = 0.0;
const double DEFAULT_FONT_WEIGHT = 400.0;

// https://drafts.csswg.org/css-text-3/
=======
// CSS Text: https://drafts.csswg.org/css-text-3/
// CSS Text Decoration: https://drafts.csswg.org/css-text-decor-3/

>>>>>>> master
mixin CSSTextMixin {

  TextSpan createTextSpanWithStyle(String text, CSSStyleDeclaration style) {
    return TextSpan(
      text: text,
      style: getTextStyle(style),
    );
  }

  TextAlign getTextAlignFromStyle(CSSStyleDeclaration style) {
    TextAlign textAlign = TextAlign.left;
    switch (style['textAlign']) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'left':
      default:
        textAlign = TextAlign.left;
        break;
    }
    return textAlign;
  }

  /// TextStyle({
  ///   Color color,
  ///   TextDecoration decoration,
  ///   Color decorationColor,
  ///   TextDecorationStyle decorationStyle,
  ///   FontWeight fontWeight,
  ///   FontStyle fontStyle,
  ///   TextBaseline textBaseline,
  ///   String fontFamily,
  ///   double fontSize,
  ///   double letterSpacing,
  ///   double wordSpacing,
  ///   double height,
  ///   Locale locale,
  ///   Paint background,
  ///   Paint foreground,
  ///   List<Shadow> shadows
  /// })
  ///
  /// Creates a new TextStyle object.
  ///   color: The color to use when painting the text. If this is specified, foreground must be null.
  ///   decoration: The decorations to paint near the text (e.g., an underline).
  ///   decorationColor: The color in which to paint the text decorations.
  ///   decorationStyle: The style in which to paint the text decorations (e.g., dashed).
  ///   fontWeight: The typeface thickness to use when painting the text (e.g., bold).
  ///   fontStyle: The typeface variant to use when drawing the letters (e.g., italics).
  ///   fontFamily: The name of the font to use when painting the text (e.g., Roboto).
  ///   fontSize: The size of glyphs (in logical pixels) to use when painting the text.
  ///   letterSpacing: The amount of space (in logical pixels) to add between each letter.
  ///   wordSpacing: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between /// each word).
  ///   textBaseline: The common baseline that should be aligned between this text span and its parent text span, /// or, for the root text spans, with the line box.
  ///   height: The height of this text span, as a multiple of the font size.
  ///   locale: The locale used to select region-specific glyphs.
  ///   background: The paint drawn as a background for the text.
  ///   foreground: The paint used to draw the text. If this is specified, color must be null.
  TextStyle getTextStyle(CSSStyleDeclaration style) {
    return TextStyle(
      color: getColor(style),
      decoration: getDecorationLine(style),
      decorationColor: getDecorationColor(style),
      decorationStyle: getDecorationStyle(style),
      fontWeight: getFontWeight(style),
      fontStyle: getFontStyle(style),
      textBaseline: getTextBaseLine(style),
      package: getFontPackage(style),
      fontFamily: getFontFamily(style),
      fontFamilyFallback: getFontFamilyFallback(style),
      fontSize: getFontSize(style),
      letterSpacing: getLetterSpacing(style),
      wordSpacing: getWordSpacing(style),
      height: getHeight(style),
      locale: getLocale(style),
      background: getBackground(style),
      foreground: getForeground(style),
      shadows: getShadows(style),
    );
  }

  Color getColor(CSSStyleDeclaration style) {
    if (style.contains(COLOR)) {
      return CSSColor.generate(style[COLOR]);
    } else {
      return CSSColor.black; // Default color to black.
    }
  }

  static RegExp spaceRegExp = RegExp(r' ');

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line.
  TextDecoration getDecorationLine(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_LINE)) {
      return _getTextDecorationLine(style[TEXT_DECORATION_LINE]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splittedTextDecoration = textDecoration.split(spaceRegExp);
      // Compatible with CSS 2.1: text-decoration = text-decoration-line.
      if (splittedTextDecoration.length >= 1) {
        return _getTextDecorationLine(splittedTextDecoration[0]);
      }
    }
    return _getTextDecorationLine();
  }

  TextDecoration _getTextDecorationLine([String type]) {
    if (type == 'line-through')
      return TextDecoration.lineThrough;
    else if (type == 'overline')
      return TextDecoration.overline;
    else if (type == 'underline')
      return TextDecoration.underline;
    else return TextDecoration.none;
  }

  Color getDecorationColor(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_COLOR)) {
      return CSSColor.generate(style[TEXT_DECORATION_COLOR]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splitedDecoration = textDecoration.split(spaceRegExp);
      if (splitedDecoration.length >= 2) {
        return CSSColor.generate(splitedDecoration.last);
      }
    }
    return getColor(style); // Default to currentColor (style.color)
  }

  TextDecorationStyle getDecorationStyle(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_STYLE)) {
      return _getDecorationStyle(style[TEXT_DECORATION_STYLE]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splitedDecoration = textDecoration.split(spaceRegExp);
      if (splitedDecoration.length >= 2) {
        return _getDecorationStyle(splitedDecoration[1]);
      }
    }
    return _getDecorationStyle();
  }

  TextDecorationStyle _getDecorationStyle([String value]) {
    switch (value) {
      case 'double':
        return TextDecorationStyle.double;
      case 'dotted':
        return TextDecorationStyle.dotted;
      case 'dashed':
        return TextDecorationStyle.dashed;
      case 'wavy':
        return TextDecorationStyle.wavy;
      case 'solid':
      default:
        return TextDecorationStyle.solid;
    }
  }

  FontWeight getFontWeight(CSSStyleDeclaration style) {
    if (style.contains(FONT_WEIGHT)) {
      var fontWeight = style[FONT_WEIGHT];
      double fontWeightValue = DEFAULT_FONT_WEIGHT; // Default to 400.
      if (fontWeight is String) {
        switch (fontWeight) {
          case 'lighter':
            fontWeightValue = 200;
            break;
          case 'light':
            fontWeightValue = 300;
            break;
          case 'normal':
            fontWeightValue = 400;
            break;
          case 'medium':
            fontWeightValue = 500;
            break;
          case 'bold':
            fontWeightValue = 700;
            break;
          case 'bolder':
          case 'heavy':
            fontWeightValue = 900;
            break;
          default:
            fontWeightValue =
                double.tryParse(fontWeight) ?? DEFAULT_FONT_WEIGHT;
            break;
        }
      }

      if (fontWeightValue >= 900) {
        return FontWeight.w900;
      } else if (fontWeightValue >= 800) {
        return FontWeight.w800;
      } else if (fontWeightValue >= 700) {
        return FontWeight.w700;
      } else if (fontWeightValue >= 600) {
        return FontWeight.w600;
      } else if (fontWeightValue >= 500) {
        return FontWeight.w500;
      } else if (fontWeightValue >= 400) {
        return FontWeight.w400;
      } else if (fontWeightValue >= 300) {
        return FontWeight.w300;
      } else if (fontWeightValue >= 200) {
        return FontWeight.w200;
      } else {
        return FontWeight.w100;
      }
    }
    return FontWeight.normal;
  }

  FontStyle getFontStyle(CSSStyleDeclaration style) {
    if (style.contains(FONT_STYLE)) {
      switch (style[FONT_STYLE]) {
        case 'oblique':
        case 'italic':
          return FontStyle.italic;
        case 'normal':
          return FontStyle.normal;
      }
    }
    return FontStyle.normal;
  }

  TextBaseline getTextBaseLine(CSSStyleDeclaration style) {
    return TextBaseline.alphabetic; // @TODO: impl vertical-align
  }

  static String BUILTIN_FONT_PACKAGE = null;
  String getFontPackage(CSSStyleDeclaration style) {
    return BUILTIN_FONT_PACKAGE;
  }

  static String DEFAULT_FONT_FAMILY = '';
  String getFontFamily(CSSStyleDeclaration style) {
    return style.contains(FONT_FAMILY)
      ? style[FONT_FAMILY]
      : DEFAULT_FONT_FAMILY;
  }

  static List<String> DEFAULT_FONT_FAMILY_FALLBACK = null;
  List<String> getFontFamilyFallback(CSSStyleDeclaration style) {
    return DEFAULT_FONT_FAMILY_FALLBACK;
  }

  double getFontSize(CSSStyleDeclaration style) {
    if (style.contains(FONT_SIZE)) {
      return CSSLength.toDisplayPortValue(style[FONT_SIZE]);
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  double getLetterSpacing(CSSStyleDeclaration style) {
    if (style.contains(LETTER_SPACING)) {
      String _letterSpacing = style[LETTER_SPACING];
      if (_letterSpacing == NORMAL) return DEFAULT_LETTER_SPACING;

      return CSSLength.toDisplayPortValue(_letterSpacing);
    } else {
      return DEFAULT_LETTER_SPACING;
    }
  }

  double getWordSpacing(CSSStyleDeclaration style) {
    if (style.contains(WORD_SPACING)) {
      String _wordSpacing = style[WORD_SPACING];
      if (_wordSpacing == NORMAL) return DEFAULT_WORD_SPACING;

      return CSSLength.toDisplayPortValue(_wordSpacing);
    } else {
      return DEFAULT_WORD_SPACING;
    }
  }

  double getHeight(CSSStyleDeclaration style) {
    if (style.contains(LINE_HEIGHT)) {
      return CSSLength.toDisplayPortValue(style[LINE_HEIGHT]) / getFontSize(style);
    } else {
      return null;
    }
  }

  Locale getLocale(CSSStyleDeclaration style) {
    // TODO: impl locale for text decoration.
    return null;
  }

  Paint getBackground(CSSStyleDeclaration style) {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  Paint getForeground(CSSStyleDeclaration style) {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  static RegExp commaRegExp = RegExp(r',');
  List<Shadow> getShadows(CSSStyleDeclaration style) {
    List<Shadow> textShadows = [];
    if (style.contains('textShadow')) {
      String processedValue =
          CSSColor.preprocessCSSPropertyWithRGBAColor(style['textShadow']);
      List<String> rawShadows = processedValue.split(commaRegExp);
      for (String rawShadow in rawShadows) {
        List<String> shadowDefinitions = rawShadow.trim().split(spaceRegExp);
        if (shadowDefinitions.length > 2) {
          double offsetX = CSSLength.toDisplayPortValue(shadowDefinitions[0]);
          double offsetY = CSSLength.toDisplayPortValue(shadowDefinitions[1]);
          double blurRadius = shadowDefinitions.length > 3
              ? CSSLength.toDisplayPortValue(shadowDefinitions[2])
              : 0.0;
          Color color = CSSColor.generate(shadowDefinitions.last);
          if (color != null) {
            textShadows.add(Shadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              color: color,
            ));
          }
        }
      }
    }
    return textShadows;
  }
}
