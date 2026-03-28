import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import {
  StyleSheet, Text, View, ScrollView, TouchableOpacity,
  Linking, SafeAreaView
} from 'react-native';

const C = {
  bg: '#090B13', surface: '#10141F', card: '#161C2C', border: '#1F2740',
  gold: '#C9A04A', goldFaint: 'rgba(201,160,74,0.1)',
  text: '#EDE8DF', mid: '#7A85A0', dim: '#343D55',
};

const CATS = [
  {
    id: 'ear', emoji: '🎵', name: 'Musik & Gehör', color: '#E8A838',
    sub: 'Ear Training für Pianisten',
    modus: ['🚶 Zu Fuß', '🚋 Bus/Bahn'],
    sections: [
      { title: 'Apps', items: [
        { name: 'Functional Ear Trainer', desc: 'Strukturiertes Training: Intervalle → Akkorde → Skalen. Sehr empfohlen als Einstieg.', link: 'https://play.google.com/store/apps/details?id=com.kaizen9.fet.android', linkLabel: 'Play Store' },
        { name: 'Perfect Ear', desc: 'Breiter aufgestellt: auch Rhythmus, Notenlernen, Diktate. Gut als Ergänzung.', link: 'https://play.google.com/store/apps/details?id=com.evilduck.musiciankit', linkLabel: 'Play Store' },
      ]},
      { title: 'Tipps', items: [
        { name: '10 Minuten reichen', desc: '3–4× pro Woche à 10 min ist effektiver als seltene lange Sessions.' },
        { name: 'Akkord-Fokus als Pianist', desc: 'Starte mit Dur/Moll-Erkennung — das zahlt sich direkt beim Spielen aus.' },
        { name: 'Aktiv hören', desc: 'Beim Musikhören unterwegs bewusst auf Harmonik und Struktur achten.' },
      ]},
    ]
  },
  {
    id: 'jung', emoji: '🧠', name: 'Carl Jung', color: '#9B7FD4',
    sub: 'Tiefenpsychologie & Archetypen',
    modus: ['🚶 Podcast', '🚋🚂 Bücher'],
    sections: [
      { title: 'Bücher — empfohlene Reihenfolge', items: [
        { name: '① Memories, Dreams, Reflections', desc: 'Jungs Autobiografie. Sehr persönlich, fast wie Lore — bester Einstieg.', badge: 'Start hier' },
        { name: '② Man and His Symbols', desc: 'Visuell, für Laien, ideal in der Bahn. Erklärt Archetypen ohne Vorwissen.', badge: 'Einsteiger' },
        { name: '③ Psychological Types', desc: 'Grundlage von MBTI. Wie Jung Persönlichkeit klassifiziert hat.', badge: 'Mittelstufe' },
        { name: '④ The Archetypes and the Collective Unconscious', desc: 'Tief ins kollektive Unbewusste. Für wenn du schon vertraut bist.', badge: 'Fortgeschritten' },
      ]},
      { title: 'Podcast', items: [
        { name: 'This Jungian Life', desc: 'Drei Jungianische Analytiker wöchentlich: Schatten, Träume, Anima, Archetypen.', link: 'https://thisjungianlife.com', linkLabel: 'thisjungianlife.com' },
      ]},
      { title: 'Schlüsselbegriffe', items: [
        { name: 'Schatten', desc: 'Der verdrängte Teil der Persönlichkeit — das was wir an anderen nervig finden, steckt oft in uns.' },
        { name: 'Anima / Animus', desc: 'Die weibliche Seite im Mann (Anima) / die männliche in der Frau (Animus).' },
        { name: 'Archetyp', desc: 'Universelle Urbilder im kollektiven Unbewussten: Held, Weise, Trickster…' },
        { name: 'Individuation', desc: 'Jungs Ziel: das Selbst vollständig werden, den Schatten integrieren.' },
      ]},
    ]
  },
  {
    id: 'japanese', emoji: '🇯🇵', name: 'Japanisch', color: '#E05C5C',
    sub: 'Strukturierter Lernstack',
    modus: ['🚶 Pimsleur', '🚋🚂 Apps'],
    sections: [
      { title: 'Lernreihenfolge', items: [
        { name: 'Woche 1–2: Schriften', desc: 'Hiragana (46) + Katakana (46) lernen. Je eine Woche.', badge: 'Zuerst' },
        { name: 'Ab Woche 3: Vokabeln + Kanji', desc: 'Anki (Core 2000) und Wanikani parallel starten. Täglich 10–15 min.', badge: 'Dann' },
        { name: 'Ab Monat 2: Grammatik', desc: 'Bunpro einführen sobald erste Vokabeln sitzen.', badge: 'Danach' },
      ]},
      { title: 'Apps & Tools', items: [
        { name: 'Anki — Core 2000 Deck', desc: 'Vokabel-SRS. Die 2000 häufigsten japanischen Wörter. Täglich 10–15 min.', link: 'https://ankiweb.net', linkLabel: 'ankiweb.net' },
        { name: 'Wanikani', desc: 'Kanji via SRS, sehr durchdacht. Kostenlos bis Level 3.', link: 'https://www.wanikani.com', linkLabel: 'wanikani.com' },
        { name: 'Bunpro', desc: 'Grammatik-SRS nach JLPT-Stufen. Sehr strukturiert. Gut im Zug.', link: 'https://bunpro.jp', linkLabel: 'bunpro.jp' },
        { name: 'Pimsleur', desc: 'Audio-Kurs: Hören & Sprechen. Perfekt zu Fuß, hands-free.', badge: '🚶 Zu Fuß ✓' },
      ]},
      { title: 'Was ist SRS?', items: [
        { name: 'Spaced Repetition System', desc: 'Algorithmus der Karten genau dann wiederholt wenn du kurz vor dem Vergessen bist. Extrem effizient.' },
      ]},
    ]
  },
  {
    id: 'sami', emoji: '🌿', name: 'Nordsamisch', color: '#4DB87A',
    sub: 'Sprache eines indigenen Volkes',
    modus: ['🚋 Bus/Bahn', '🚂 Zug'],
    sections: [
      { title: 'Ressourcen', items: [
        { name: 'Oahpa!', desc: 'Interaktives Lernprogramm der Universität Tromsø. Vokabeln, Grammatik, Aussprache.', link: 'https://oahpa.no', linkLabel: 'oahpa.no' },
        { name: 'Anki — Sami Deck', desc: "Handgemachte Vokabelkarten. Suche nach 'North Sami' oder 'Davvisámegiella'.", link: 'https://ankiweb.net', linkLabel: 'ankiweb.net' },
        { name: 'UiT Tromsø Materialien', desc: 'Kostenlose Lernmaterialien auf Englisch und Norwegisch.', link: 'https://uit.no', linkLabel: 'uit.no' },
      ]},
      { title: 'Tipps', items: [
        { name: '2–3× pro Woche, entspannt', desc: 'Parallel zu Japanisch als Curiosity Track. Kein Druck.' },
        { name: 'Dein Kumpel ist die beste Ressource', desc: 'Frag ihn nach Alltagsausdrücken, Aussprache, Geschichten.' },
        { name: 'Grundfakten', desc: 'Ca. 25.000 Sprecher in Norwegen, Schweden, Finnland. Uralische Sprachfamilie.' },
      ]},
    ]
  },
  {
    id: 'papers', emoji: '📄', name: 'BA-Paper', color: '#4D9BD5',
    sub: 'Literatur für deine Bachelorarbeit',
    modus: ['🚂 Zug — Deep Focus'],
    sections: [
      { title: '🔴 Must-Read', items: [
        { name: 'Dean & Barroso — The Tail at Scale (2013)', desc: 'Schicht-3-Fundament. Tail-Latency-Amplification, Shared Fate. Google / Comm. of the ACM.', badge: 'Prio 1' },
        { name: 'Langley et al. — QUIC Transport Protocol (2017)', desc: 'Schicht 1 & 2: TCP vs. QUIC, TLS-Integration. SIGCOMM.', badge: 'Prio 1' },
      ]},
      { title: '🟡 Wichtig', items: [
        { name: 'Calder et al. — Google Serving Infrastructure (2013)', desc: 'DNS & Traceroute Methodik — fast 1:1 deine Schicht-1-Methode. IMC.', badge: 'Schicht 1' },
        { name: 'Ager et al. — Comparing DNS Resolvers (2010)', desc: 'DNS-Analyse, Anycast — direkt für deine dig-Messungen. IMC.', badge: 'Schicht 1' },
        { name: 'Paxson — End-to-End Packet Dynamics (1997)', desc: 'Klassiker für Paket-Timing. Grundlegend für Schicht 2. SIGCOMM.', badge: 'Schicht 2' },
      ]},
      { title: '🟢 Kontext', items: [
        { name: 'Kostopoulos — Measuring Tail Latency (2020)', desc: 'Statistische Methoden — hilft Schicht 3 methodisch zu untermauern.', badge: 'Schicht 3' },
        { name: 'Holmer — WebRTC & Real-Time (2013)', desc: 'Voice-Pipeline-Latenz aus der Praxis. Für Einleitung & Diskussion.', badge: 'Kontext' },
      ]},
      { title: 'Wo finden', items: [
        { name: 'Google Scholar', desc: 'Einfachste Suche — Titel eingeben, PDF-Link suchen.', link: 'https://scholar.google.com', linkLabel: 'scholar.google.com' },
        { name: 'Semantic Scholar', desc: 'Gut für Zitationsnetzwerke und verwandte Paper.', link: 'https://www.semanticscholar.org', linkLabel: 'semanticscholar.org' },
        { name: 'ACM Digital Library', desc: 'Offiziell für SIGCOMM, IMC, CACM Paper.', link: 'https://dl.acm.org', linkLabel: 'dl.acm.org' },
      ]},
    ]
  },
  {
    id: 'pods', emoji: '🎙️', name: 'Tech-Podcasts', color: '#FF6F3C',
    sub: 'KI & Softwareentwicklung',
    modus: ['🚶 Zu Fuß', '🚋 Bus/Bahn'],
    sections: [
      { title: 'Podcasts', items: [
        { name: 'Latent Space', desc: 'KI/ML tief — Interviews mit Leuten die Modelle bauen. Passt zu deiner Thesis.', link: 'https://www.latent.space/podcast', linkLabel: 'latent.space' },
        { name: 'The Cognitive Revolution', desc: 'KI-Anwendungen, Policy, Gesellschaft. Gute Tiefe.', link: 'https://www.cognitiverevolution.ai', linkLabel: 'cognitiverevolution.ai' },
        { name: 'Practical AI', desc: 'Leicht verdaulich, wöchentlich, gut für den Überblick.', link: 'https://changelog.com/practicalai', linkLabel: 'changelog.com' },
      ]},
      { title: 'Tipps', items: [
        { name: 'Offline speichern', desc: 'Episoden vor dem Losfahren runterladen — Pocket Casts oder Spotify.' },
        { name: 'Playback-Speed', desc: '1.25–1.5× wenn du mit dem Stil vertraut bist.' },
        { name: 'Stichpunkte notieren', desc: 'Kurz in Notiz-App tippen was interessant war — hilft beim Erinnern.' },
      ]},
    ]
  },
  {
    id: 'plan', emoji: '📅', name: 'Wochenplan', color: '#C9A04A',
    sub: 'Wann was — je nach Kontext',
    modus: ['Alle Modi'],
    sections: [
      { title: 'Wochenplan', items: [
        { name: 'Montag', desc: '🎵 Ear Training + 🇯🇵 Japanisch (Anki)', badge: 'Mo' },
        { name: 'Dienstag', desc: '🧠 Jung Podcast (zu Fuß) + 🌿 Nordsamisch (Oahpa)', badge: 'Di' },
        { name: 'Mittwoch', desc: '🎙️ Tech-Podcast + 📄 BA-Paper (Zug)', badge: 'Mi' },
        { name: 'Donnerstag', desc: '🇯🇵 Japanisch Wanikani/Bunpro + 🎵 Ear Training', badge: 'Do' },
        { name: 'Freitag', desc: '🧠 Jung Buch (Bahn)', badge: 'Fr' },
        { name: 'Samstag', desc: '🌿 Nordsamisch + 🇯🇵 Japanisch Anki', badge: 'Sa' },
        { name: 'Sonntag', desc: '🧠 Jung + 🎙️ Tech-Podcast', badge: 'So' },
      ]},
      { title: 'Faustregel nach Modus', items: [
        { name: '🚶 Zu Fuß / Fahrrad', desc: 'Nur Audio — Podcasts, Pimsleur, This Jungian Life.', badge: 'Audio only' },
        { name: '🚋 Bus / Straßenbahn', desc: 'Audio + Apps — Anki, Wanikani, Bunpro, Oahpa!, Ear Trainer.', badge: 'Audio + Apps' },
        { name: '🚂 Zug / lange Fahrt', desc: 'Alles — Papers lesen, Jung-Bücher, Grammatik.', badge: 'Deep Focus' },
      ]},
    ]
  },
];

function Badge({ text, color }) {
  return (
    <View style={{ backgroundColor: `${color}25`, borderRadius: 12, paddingHorizontal: 8, paddingVertical: 2, flexShrink: 0 }}>
      <Text style={{ color, fontSize: 10, fontWeight: '700' }}>{text}</Text>
    </View>
  );
}

function HomeScreen({ onSelect }) {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }}>
      <StatusBar style="light" />
      <ScrollView>
        <View style={{ padding: 24, paddingTop: 40, backgroundColor: '#0F1420', borderBottomWidth: 1, borderBottomColor: C.border }}>
          <Text style={{ fontSize: 11, color: C.gold, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 6 }}>
            Antons Lernplan
          </Text>
          <Text style={{ fontSize: 26, fontWeight: '700', color: C.text, lineHeight: 34 }}>
            Was lernst du{'\n'}heute?
          </Text>
          <Text style={{ fontSize: 13, color: C.mid, marginTop: 8 }}>Wähle einen Bereich</Text>
        </View>

        <View style={{ padding: 14, gap: 8 }}>
          {CATS.map(cat => (
            <TouchableOpacity key={cat.id} onPress={() => onSelect(cat)} activeOpacity={0.7}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 14, padding: 14,
                borderRadius: 16, backgroundColor: C.card,
                borderWidth: 1, borderColor: C.border, borderLeftWidth: 3, borderLeftColor: cat.color }}>
              <Text style={{ fontSize: 24 }}>{cat.emoji}</Text>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 15, fontWeight: '600', color: C.text }}>{cat.name}</Text>
                <Text style={{ fontSize: 11, color: C.mid, marginTop: 2 }}>{cat.sub}</Text>
              </View>
              <Text style={{ color: C.dim, fontSize: 20 }}>›</Text>
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function CategoryScreen({ cat, onBack }) {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }}>
      <ScrollView>
        {/* Hero */}
        <View style={{ padding: 20, paddingTop: 16, backgroundColor: `${cat.color}15`,
          borderBottomWidth: 1, borderBottomColor: `${cat.color}30` }}>
          <TouchableOpacity onPress={onBack} style={{ marginBottom: 20 }}>
            <Text style={{ color: C.mid, fontSize: 14 }}>← Zurück</Text>
          </TouchableOpacity>
          <Text style={{ fontSize: 34 }}>{cat.emoji}</Text>
          <Text style={{ fontSize: 22, fontWeight: '700', color: C.text, marginTop: 8, lineHeight: 28 }}>{cat.name}</Text>
          <Text style={{ fontSize: 13, color: C.mid, marginTop: 4 }}>{cat.sub}</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 14 }}>
            {cat.modus.map(m => (
              <View key={m} style={{ backgroundColor: C.surface, borderWidth: 1, borderColor: C.border,
                borderRadius: 20, paddingHorizontal: 10, paddingVertical: 4 }}>
                <Text style={{ fontSize: 11, color: C.mid }}>{m}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Sections */}
        <View style={{ padding: 14, paddingBottom: 48 }}>
          {cat.sections.map((section, si) => (
            <View key={si} style={{ marginBottom: 28 }}>
              <View style={{ borderBottomWidth: 1, borderBottomColor: `${cat.color}30`, paddingBottom: 6, marginBottom: 10 }}>
                <Text style={{ fontSize: 10, fontWeight: '700', letterSpacing: 1.5,
                  textTransform: 'uppercase', color: cat.color }}>{section.title}</Text>
              </View>
              <View style={{ gap: 8 }}>
                {section.items.map((item, ii) => (
                  <View key={ii} style={{ backgroundColor: C.card, borderWidth: 1, borderColor: C.border, borderRadius: 14, padding: 14 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8, marginBottom: 4 }}>
                      <Text style={{ fontSize: 14, fontWeight: '600', color: C.text, flex: 1, lineHeight: 20 }}>{item.name}</Text>
                      {item.badge && <Badge text={item.badge} color={cat.color} />}
                    </View>
                    <Text style={{ fontSize: 12, color: C.mid, lineHeight: 18 }}>{item.desc}</Text>
                    {item.link && (
                      <TouchableOpacity onPress={() => Linking.openURL(item.link)}
                        style={{ marginTop: 10, alignSelf: 'flex-start', backgroundColor: `${cat.color}18`,
                          borderWidth: 1, borderColor: `${cat.color}40`, borderRadius: 8,
                          paddingHorizontal: 12, paddingVertical: 6 }}>
                        <Text style={{ fontSize: 12, fontWeight: '600', color: cat.color }}>↗ {item.linkLabel}</Text>
                      </TouchableOpacity>
                    )}
                  </View>
                ))}
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

export default function App() {
  const [selected, setSelected] = useState(null);
  return selected
    ? <CategoryScreen cat={selected} onBack={() => setSelected(null)} />
    : <HomeScreen onSelect={setSelected} />;
}
