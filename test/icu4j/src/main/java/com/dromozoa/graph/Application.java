package com.dromozoa.graph;

import com.ibm.icu.lang.*;

public class Application {
  public static void main(String[] args) {
    int codePointFirst = 0;
    int codePointLast = 0x10FFFF;

    if (args != null) {
      if (args.length > 0) {
        codePointFirst = Integer.parseInt(args[0], 16);
      }
      if (args.length > 1) {
        codePointLast = Integer.parseInt(args[1], 16);
      }
    }

    for (int codePoint = codePointFirst; codePoint <= codePointLast; ++codePoint) {
      int property = UCharacter.getIntPropertyValue(codePoint, UProperty.EAST_ASIAN_WIDTH);
      switch (property) {
        case UCharacter.EastAsianWidth.AMBIGUOUS:
          System.out.println(codePoint + "\tA");
          break;
        case UCharacter.EastAsianWidth.FULLWIDTH:
          System.out.println(codePoint + "\tF");
          break;
        case UCharacter.EastAsianWidth.HALFWIDTH:
          System.out.println(codePoint + "\tH");
          break;
        case UCharacter.EastAsianWidth.NEUTRAL:
          System.out.println(codePoint + "\tN");
          break;
        case UCharacter.EastAsianWidth.NARROW:
          System.out.println(codePoint + "\tNa");
          break;
        case UCharacter.EastAsianWidth.WIDE:
          System.out.println(codePoint + "\tW");
          break;
        default:
          throw new RuntimeException();
      }
    }
  }
}
