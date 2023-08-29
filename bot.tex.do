sysuse voter, clear
tabout inc candidat using table10.txt, ///
c(mean pfrac) f(1) clab(%) sum ///
rep ///
style(tex) bt font(bold) cl1(2-5) ///
topf(top.tex) botf(bot.tex) topstr(12cm) botstr(voter.dta)
