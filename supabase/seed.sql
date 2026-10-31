-- Dev seed. DRAFT text: verify Sanskrit and Hindi meaning with a scripture reviewer before release.
-- Reels have no media yet; the app renders a gradient fallback until media_url is set.
with s as (
  insert into shloks (chapter, verse, sanskrit, hindi_meaning, themes) values
  (2, 47, E'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
   'तुम्हारा अधिकार केवल कर्म करने में है, उसके फलों में कभी नहीं। इसलिए न फल की इच्छा से कर्म करो और न कर्म न करने में आसक्त हो।',
   '{duty,equanimity}'),
  (4, 7, E'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम्॥',
   'हे भारत! जब-जब धर्म की हानि और अधर्म की वृद्धि होती है, तब-तब मैं स्वयं को प्रकट करता हूँ।',
   '{dharma,faith}'),
  (2, 22, E'वासांसि जीर्णानि यथा विहाय\nनवानि गृह्णाति नरोऽपराणि।\nतथा शरीराणि विहाय जीर्णा-\nन्यन्यानि संयाति नवानि देही॥',
   'जैसे मनुष्य पुराने वस्त्रों को त्यागकर नए वस्त्र धारण करता है, वैसे ही आत्मा पुराने शरीरों को त्यागकर नए शरीरों को प्राप्त होती है।',
   '{soul,change}'),
  (6, 5, E'उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।\nआत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥',
   'मनुष्य को अपने द्वारा अपना उद्धार करना चाहिए, अपना पतन नहीं। मनुष्य स्वयं ही अपना मित्र है और स्वयं ही अपना शत्रु है।',
   '{self-mastery,mind}')
  returning id, chapter
)
insert into reels (shlok_id, style, status, published_at, duration_s)
select id, 'devotional', 'published', now(), 20 from s;
