import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamColorScheme.fromSeed light color generation', () {
    test('generates the exact brand scale for a deep orange seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFFF5722)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFFFECE5));
      expect(brand[100], const Color(0xFFFFDBD0));
      expect(brand[150], const Color(0xFFFFCBBA));
      expect(brand[200], const Color(0xFFFFBAA4));
      expect(brand[300], const Color(0xFFFF9979));
      expect(brand[400], const Color(0xFFFF784D));
      expect(brand[500], const Color(0xFFFF5722));
      expect(brand[600], const Color(0xFFE83800));
      expect(brand[700], const Color(0xFFAF2A00));
      expect(brand[800], const Color(0xFF761C00));
      expect(brand[900], const Color(0xFF3D0F00));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a deep orange seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFFF5722)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF4F2F1));
      expect(chrome[100], const Color(0xFFEAE6E5));
      expect(chrome[150], const Color(0xFFE0DBD9));
      expect(chrome[200], const Color(0xFFD6CFCD));
      expect(chrome[300], const Color(0xFFC3B8B5));
      expect(chrome[400], const Color(0xFFAFA29D));
      expect(chrome[500], const Color(0xFF9C8B85));
      expect(chrome[600], const Color(0xFF806E68));
      expect(chrome[700], const Color(0xFF60534F));
      expect(chrome[800], const Color(0xFF413835));
      expect(chrome[900], const Color(0xFF221D1C));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('generates the exact brand scale for a purple seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF9C27B0)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFF8EAFA));
      expect(brand[100], const Color(0xFFF0D2F5));
      expect(brand[150], const Color(0xFFE8B9F0));
      expect(brand[200], const Color(0xFFDFA1EA));
      expect(brand[300], const Color(0xFFCF70DF));
      expect(brand[400], const Color(0xFFBE3FD4));
      expect(brand[500], const Color(0xFF9C27B0));
      expect(brand[600], const Color(0xFF802091));
      expect(brand[700], const Color(0xFF641971));
      expect(brand[800], const Color(0xFF481252));
      expect(brand[900], const Color(0xFF2C0B32));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a purple seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF9C27B0)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF3F1F4));
      expect(chrome[100], const Color(0xFFE5E1E6));
      expect(chrome[150], const Color(0xFFD7D0D9));
      expect(chrome[200], const Color(0xFFC9C0CB));
      expect(chrome[300], const Color(0xFFAE9FB0));
      expect(chrome[400], const Color(0xFF927E95));
      expect(chrome[500], const Color(0xFF736176));
      expect(chrome[600], const Color(0xFF5F4F61));
      expect(chrome[700], const Color(0xFF4A3E4C));
      expect(chrome[800], const Color(0xFF352D37));
      expect(chrome[900], const Color(0xFF211C22));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('generates the exact brand scale for a yellow seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFFFEB3B)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFFFFCE5));
      expect(brand[100], const Color(0xFFFFFAD3));
      expect(brand[150], const Color(0xFFFFF9C0));
      expect(brand[200], const Color(0xFFFFF7AD));
      expect(brand[300], const Color(0xFFFFF387));
      expect(brand[400], const Color(0xFFFFEF61));
      expect(brand[500], const Color(0xFFFFEB3B));
      expect(brand[600], const Color(0xFFFBE100));
      expect(brand[700], const Color(0xFFBCA800));
      expect(brand[800], const Color(0xFF7C7000));
      expect(brand[900], const Color(0xFF3D3700));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a yellow seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFFFEB3B)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF4F3F1));
      expect(chrome[100], const Color(0xFFEBEBE7));
      expect(chrome[150], const Color(0xFFE2E2DC));
      expect(chrome[200], const Color(0xFFDAD9D2));
      expect(chrome[300], const Color(0xFFC9C8BD));
      expect(chrome[400], const Color(0xFFB8B6A8));
      expect(chrome[500], const Color(0xFFA7A593));
      expect(chrome[600], const Color(0xFF8A8771));
      expect(chrome[700], const Color(0xFF676554));
      expect(chrome[800], const Color(0xFF444338));
      expect(chrome[900], const Color(0xFF22211C));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('generates the exact brand scale for a green seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF4CAF50)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFEDF7EE));
      expect(brand[100], const Color(0xFFDBEFDC));
      expect(brand[150], const Color(0xFFC9E8CA));
      expect(brand[200], const Color(0xFFB7E0B9));
      expect(brand[300], const Color(0xFF93D095));
      expect(brand[400], const Color(0xFF6FC072));
      expect(brand[500], const Color(0xFF4CAF50));
      expect(brand[600], const Color(0xFF3E8E41));
      expect(brand[700], const Color(0xFF2F6D32));
      expect(brand[800], const Color(0xFF214C23));
      expect(brand[900], const Color(0xFF132B14));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a green seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF4CAF50)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF1F4F1));
      expect(chrome[100], const Color(0xFFE3E8E3));
      expect(chrome[150], const Color(0xFFD4DCD5));
      expect(chrome[200], const Color(0xFFC6D1C7));
      expect(chrome[300], const Color(0xFFAAB9AA));
      expect(chrome[400], const Color(0xFF8DA28E));
      expect(chrome[500], const Color(0xFF718A72));
      expect(chrome[600], const Color(0xFF5C705C));
      expect(chrome[700], const Color(0xFF465647));
      expect(chrome[800], const Color(0xFF313C31));
      expect(chrome[900], const Color(0xFF1C221C));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('generates the exact brand scale for a blue seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF2196F3)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFE7F4FE));
      expect(brand[100], const Color(0xFFD1E9FD));
      expect(brand[150], const Color(0xFFBBDFFB));
      expect(brand[200], const Color(0xFFA5D4FA));
      expect(brand[300], const Color(0xFF79C0F8));
      expect(brand[400], const Color(0xFF4DABF5));
      expect(brand[500], const Color(0xFF2196F3));
      expect(brand[600], const Color(0xFF0B7BD3));
      expect(brand[700], const Color(0xFF095DA0));
      expect(brand[800], const Color(0xFF063F6D));
      expect(brand[900], const Color(0xFF03223A));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a blue seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF2196F3)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF1F2F4));
      expect(chrome[100], const Color(0xFFE4E7E9));
      expect(chrome[150], const Color(0xFFD7DBDF));
      expect(chrome[200], const Color(0xFFCBD0D4));
      expect(chrome[300], const Color(0xFFB1B9BF));
      expect(chrome[400], const Color(0xFF98A2AB));
      expect(chrome[500], const Color(0xFF7E8B96));
      expect(chrome[600], const Color(0xFF64707A));
      expect(chrome[700], const Color(0xFF4C555D));
      expect(chrome[800], const Color(0xFF343A3F));
      expect(chrome[900], const Color(0xFF1C1F22));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('generates the exact brand scale for a red seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFF44336)).brand;

      expect(brand[0], const Color(0xFFFFFFFF));
      expect(brand[50], const Color(0xFFFEE8E7));
      expect(brand[100], const Color(0xFFFDD6D3));
      expect(brand[150], const Color(0xFFFCC4C0));
      expect(brand[200], const Color(0xFFFAB1AC));
      expect(brand[300], const Color(0xFFF88D85));
      expect(brand[400], const Color(0xFFF6685D));
      expect(brand[500], const Color(0xFFF44336));
      expect(brand[600], const Color(0xFFE21B0C));
      expect(brand[700], const Color(0xFFAA1409));
      expect(brand[800], const Color(0xFF720E06));
      expect(brand[900], const Color(0xFF3A0703));
      expect(brand[1000], const Color(0xFF000000));
    });

    test('generates the exact auto-derived chrome scale for a red seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFF44336)).chrome;

      expect(chrome[0], const Color(0xFFFFFFFF));
      expect(chrome[50], const Color(0xFFF4F1F1));
      expect(chrome[100], const Color(0xFFEAE6E6));
      expect(chrome[150], const Color(0xFFE1DBDA));
      expect(chrome[200], const Color(0xFFD8CFCF));
      expect(chrome[300], const Color(0xFFC5B9B8));
      expect(chrome[400], const Color(0xFFB2A2A1));
      expect(chrome[500], const Color(0xFFA08C8A));
      expect(chrome[600], const Color(0xFF836D6B));
      expect(chrome[700], const Color(0xFF635251));
      expect(chrome[800], const Color(0xFF423736));
      expect(chrome[900], const Color(0xFF221C1C));
      expect(chrome[1000], const Color(0xFF000000));
    });

    test('uses the seed color unchanged as brand shade 500', () {
      const seed = Color(0xFF2196F3);

      final brand = StreamColorScheme.fromSeed(brand: seed).brand;

      expect(brand[500], seed);
    });
  });

  group('StreamColorScheme.fromSeed dark color generation', () {
    test('generates the exact brand scale for a deep orange seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFFF5722), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF3D0F00));
      expect(brand[100], const Color(0xFF571500));
      expect(brand[150], const Color(0xFF701B00));
      expect(brand[200], const Color(0xFF892100));
      expect(brand[300], const Color(0xFFBC2D00));
      expect(brand[400], const Color(0xFFEE3900));
      expect(brand[500], const Color(0xFFFF5722));
      expect(brand[600], const Color(0xFFFF7C53));
      expect(brand[700], const Color(0xFFFFA184));
      expect(brand[800], const Color(0xFFFFC6B5));
      expect(brand[900], const Color(0xFFFFECE5));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a deep orange seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFFF5722), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF221D1C));
      expect(chrome[100], const Color(0xFF302927));
      expect(chrome[150], const Color(0xFF3E3532));
      expect(chrome[200], const Color(0xFF4B413E));
      expect(chrome[300], const Color(0xFF675954));
      expect(chrome[400], const Color(0xFF83716B));
      expect(chrome[500], const Color(0xFF9C8B85));
      expect(chrome[600], const Color(0xFFB2A4A0));
      expect(chrome[700], const Color(0xFFC8BEBB));
      expect(chrome[800], const Color(0xFFDED8D6));
      expect(chrome[900], const Color(0xFFF4F2F1));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact brand scale for a purple seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF9C27B0), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF2C0B32));
      expect(brand[100], const Color(0xFF390E40));
      expect(brand[150], const Color(0xFF45114E));
      expect(brand[200], const Color(0xFF52145C));
      expect(brand[300], const Color(0xFF6A1B78));
      expect(brand[400], const Color(0xFF832194));
      expect(brand[500], const Color(0xFF9C27B0));
      expect(brand[600], const Color(0xFFC145D6));
      expect(brand[700], const Color(0xFFD37CE2));
      expect(brand[800], const Color(0xFFE6B3EE));
      expect(brand[900], const Color(0xFFF8EAFA));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a purple seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF9C27B0), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF211C22));
      expect(chrome[100], const Color(0xFF2A232B));
      expect(chrome[150], const Color(0xFF332B34));
      expect(chrome[200], const Color(0xFF3C333E));
      expect(chrome[300], const Color(0xFF4F4251));
      expect(chrome[400], const Color(0xFF615163));
      expect(chrome[500], const Color(0xFF736176));
      expect(chrome[600], const Color(0xFF958299));
      expect(chrome[700], const Color(0xFFB5A7B7));
      expect(chrome[800], const Color(0xFFD4CCD5));
      expect(chrome[900], const Color(0xFFF3F1F4));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact brand scale for a yellow seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFFFEB3B), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF3D3700));
      expect(brand[100], const Color(0xFF595000));
      expect(brand[150], const Color(0xFF756900));
      expect(brand[200], const Color(0xFF918300));
      expect(brand[300], const Color(0xFFCAB500));
      expect(brand[400], const Color(0xFFFFE503));
      expect(brand[500], const Color(0xFFFFEB3B));
      expect(brand[600], const Color(0xFFFFEF66));
      expect(brand[700], const Color(0xFFFFF490));
      expect(brand[800], const Color(0xFFFFF8BB));
      expect(brand[900], const Color(0xFFFFFCE5));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a yellow seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFFFEB3B), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF22211C));
      expect(chrome[100], const Color(0xFF313028));
      expect(chrome[150], const Color(0xFF413F35));
      expect(chrome[200], const Color(0xFF504F41));
      expect(chrome[300], const Color(0xFF6F6D5B));
      expect(chrome[400], const Color(0xFF8E8B74));
      expect(chrome[500], const Color(0xFFA7A593));
      expect(chrome[600], const Color(0xFFBAB8AB));
      expect(chrome[700], const Color(0xFFCDCCC2));
      expect(chrome[800], const Color(0xFFE0E0DA));
      expect(chrome[900], const Color(0xFFF4F3F1));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact brand scale for a green seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF4CAF50), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF132B14));
      expect(brand[100], const Color(0xFF19391A));
      expect(brand[150], const Color(0xFF1F4821));
      expect(brand[200], const Color(0xFF265728));
      expect(brand[300], const Color(0xFF327435));
      expect(brand[400], const Color(0xFF3F9243));
      expect(brand[500], const Color(0xFF4CAF50));
      expect(brand[600], const Color(0xFF73C276));
      expect(brand[700], const Color(0xFF9CD49E));
      expect(brand[800], const Color(0xFFC5E6C6));
      expect(brand[900], const Color(0xFFEDF7EE));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a green seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF4CAF50), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF1C221C));
      expect(chrome[100], const Color(0xFF252D25));
      expect(chrome[150], const Color(0xFF2F392F));
      expect(chrome[200], const Color(0xFF384439));
      expect(chrome[300], const Color(0xFF4B5C4C));
      expect(chrome[400], const Color(0xFF5E735F));
      expect(chrome[500], const Color(0xFF718A72));
      expect(chrome[600], const Color(0xFF91A591));
      expect(chrome[700], const Color(0xFFB1BFB1));
      expect(chrome[800], const Color(0xFFD1D9D1));
      expect(chrome[900], const Color(0xFFF1F4F1));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact brand scale for a blue seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFF2196F3), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF03223A));
      expect(brand[100], const Color(0xFF042F51));
      expect(brand[150], const Color(0xFF063C67));
      expect(brand[200], const Color(0xFF07497E));
      expect(brand[300], const Color(0xFF0964AB));
      expect(brand[400], const Color(0xFF0C7ED9));
      expect(brand[500], const Color(0xFF2196F3));
      expect(brand[600], const Color(0xFF52ADF6));
      expect(brand[700], const Color(0xFF84C5F8));
      expect(brand[800], const Color(0xFFB5DCFB));
      expect(brand[900], const Color(0xFFE7F4FE));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a blue seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFF2196F3), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF1C1F22));
      expect(chrome[100], const Color(0xFF262B2F));
      expect(chrome[150], const Color(0xFF31373C));
      expect(chrome[200], const Color(0xFF3C4349));
      expect(chrome[300], const Color(0xFF515B63));
      expect(chrome[400], const Color(0xFF67737E));
      expect(chrome[500], const Color(0xFF7E8B96));
      expect(chrome[600], const Color(0xFF9BA5AD));
      expect(chrome[700], const Color(0xFFB8BFC5));
      expect(chrome[800], const Color(0xFFD4D9DC));
      expect(chrome[900], const Color(0xFFF1F2F4));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact brand scale for a red seed', () {
      final brand = StreamColorScheme.fromSeed(brand: const Color(0xFFF44336), brightness: .dark).brand;

      expect(brand[0], const Color(0xFF000000));
      expect(brand[50], const Color(0xFF3A0703));
      expect(brand[100], const Color(0xFF530A05));
      expect(brand[150], const Color(0xFF6C0D06));
      expect(brand[200], const Color(0xFF851007));
      expect(brand[300], const Color(0xFFB7160A));
      expect(brand[400], const Color(0xFFE91C0D));
      expect(brand[500], const Color(0xFFF44336));
      expect(brand[600], const Color(0xFFF66C62));
      expect(brand[700], const Color(0xFFF9968E));
      expect(brand[800], const Color(0xFFFBBFBB));
      expect(brand[900], const Color(0xFFFEE8E7));
      expect(brand[1000], const Color(0xFFFFFFFF));
    });

    test('generates the exact auto-derived chrome scale for a red seed', () {
      final chrome = StreamColorScheme.fromSeed(brand: const Color(0xFFF44336), brightness: .dark).chrome;

      expect(chrome[0], const Color(0xFF000000));
      expect(chrome[50], const Color(0xFF221C1C));
      expect(chrome[100], const Color(0xFF302827));
      expect(chrome[150], const Color(0xFF3F3433));
      expect(chrome[200], const Color(0xFF4D403F));
      expect(chrome[300], const Color(0xFF6A5857));
      expect(chrome[400], const Color(0xFF87706E));
      expect(chrome[500], const Color(0xFFA08C8A));
      expect(chrome[600], const Color(0xFFB5A5A4));
      expect(chrome[700], const Color(0xFFCABEBE));
      expect(chrome[800], const Color(0xFFDFD8D7));
      expect(chrome[900], const Color(0xFFF4F1F1));
      expect(chrome[1000], const Color(0xFFFFFFFF));
    });

    test('uses the seed color unchanged as brand shade 500', () {
      const seed = Color(0xFF2196F3);

      final brand = StreamColorScheme.fromSeed(brand: seed, brightness: .dark).brand;

      expect(brand[500], seed);
    });
  });
}
