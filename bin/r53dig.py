#!/usr/bin/env python3
# Utility to check for availability of domain names availabe for registration on AWS Route 53
import argparse
import subprocess

# https://aws.amazon.com/route53/pricing/
# updated 2019-12-04
AWS_DOMAINS = """ac $48.00 $48.00 $48.00 $0.00 No change
academy $32.00 $0.00 $83.00 $32.00 Renewed with transfer
accountants $94.00 $0.00 $145.00 $94.00 Renewed with transfer
adult $100.00 $0.00 $160.00 $100.00 Renewed with transfer
agency $19.00 $0.00 $73.00 $19.00 Renewed with transfer
apartments $47.00 $0.00 $100.00 $47.00 Renewed with transfer
associates $29.00 $0.00 $83.00 $29.00 Renewed with transfer
auction $29.00 $0.00 $83.00 $29.00 Renewed with transfer
audio $13.00* $0.00 Not supported Not supported Not supported
band $22.00 $0.00 $76.00 $22.00 Renewed with transfer
bargains $30.00 $0.00 $83.00 $30.00 Renewed with transfer
be $9.00 $9.00 $19.00 $9.00 Renewed with transfer
berlin $52.00 $0.00 $235.00 $52.00 Renewed with transfer
bike $32.00 $0.00 $83.00 $32.00 Renewed with transfer
bingo $47.00 $0.00 $100.00 $47.00 Renewed with transfer
biz $16.00 $0.00 $72.00 $16.00 Renewed with transfer
black $43.00 $0.00 $96.00 $43.00 Renewed with transfer
blue $15.00 $0.00 $69.00 $15.00 Renewed with transfer
boutique $30.00 $0.00 $83.00 $30.00 Renewed with transfer
builders $32.00 $0.00 $83.00 $32.00 Renewed with transfer
business $18.00 $0.00 $62.00 $18.00 Renewed with transfer
buzz $37.00 $0.00 $89.00 $37.00 Renewed with transfer
ca $13.00 $0.00 $13.00 $13.00 Renewed with transfer
cab $32.00 $0.00 $83.00 $32.00 Renewed with transfer
cafe $31.00 $0.00 $89.00 $31.00 Renewed with transfer
camera $46.00 $0.00 $100.00 $46.00 Renewed with transfer
camp $46.00 $0.00 $100.00 $46.00 Renewed with transfer
capital $47.00 $0.00 $100.00 $47.00 Renewed with transfer
cards $29.00 $0.00 $83.00 $29.00 Renewed with transfer
care $29.00 $0.00 $83.00 $29.00 Renewed with transfer
careers $35.00 $0.00 $100.00 $35.00 Renewed with transfer
cash $29.00 $0.00 $83.00 $29.00 Renewed with transfer
casino $141.00 $0.00 $190.00 $141.00 Renewed with transfer
catering $29.00 $0.00 $83.00 $29.00 Renewed with transfer
cc $12.00 $0.00 $66.00 $12.00 Renewed with transfer
center $21.00 $0.00 $73.00 $21.00 Renewed with transfer
ceo $74.00 $0.00 $151.00 $74.00 Renewed with transfer
ch $12.00 $0.00 $12.00 $0.00 No change
chat $29.00 $0.00 $83.00 $29.00 Renewed with transfer
cheap $30.00 $0.00 $83.00 $30.00 Renewed with transfer
church $29.00 $0.00 $83.00 $29.00 Renewed with transfer
city $19.00 $0.00 $73.00 $19.00 Renewed with transfer
cl $93.00* $93.00 Not supported Not supported Not supported
cloud $23.00 $0.00 $82.00 $23.00 Renewed with transfer
claims $47.00 $0.00 $100.00 $47.00 Renewed with transfer
cleaning $46.00 $0.00 $100.00 $46.00 Renewed with transfer
click $10.00 $0.00 $48.00 $10.00 Renewed with transfer
clinic $47.00 $0.00 $100.00 $47.00 Renewed with transfer
clothing $32.00 $0.00 $83.00 $32.00 Renewed with transfer
club $12.00 $0.00 $66.00 $12.00 Renewed with transfer
co $25.00 $0.00 $62.00 $25.00 Renewed with transfer
co.nz $24.00 $0.00 $24.00 $24.00 Renewed with transfer
co.uk $9.00 $0.00 $9.00 $0.00 No change
co.za $13.00 $0.00 $13.00 $0.00 No change
coach $47.00 $0.00 $100.00 $47.00 Renewed with transfer
codes $35.00 $0.00 $100.00 $35.00 Renewed with transfer
coffee $32.00 $0.00 $83.00 $32.00 Renewed with transfer
college $69.00 $0.00 $436.00 $69.00 Renewed with transfer
com $12.00 $0.00 $66.00 $12.00 Renewed with transfer
com.ar $76.00* $76.00 Not supported Not supported Not supported
com.au $15.00 $40.00 $60.00 $0.00 No change
com.br $58.00* $58.00 Not supported Not supported Not supported
com.mx $34.00 $0.00 $67.00 $34.00 Renewed with transfer
com.sg $47.00* $47.00 Not supported Not supported Not supported
community $29.00 $0.00 $83.00 $29.00 Renewed with transfer
company $18.00 $0.00 $62.00 $18.00 Renewed with transfer
computer $32.00 $0.00 $83.00 $32.00 Renewed with transfer
condos $49.00 $0.00 $100.00 $49.00 Renewed with transfer
construction $32.00 $0.00 $83.00 $32.00 Renewed with transfer
consulting $29.00 $0.00 $83.00 $29.00 Renewed with transfer
contractors $32.00 $0.00 $83.00 $32.00 Renewed with transfer
cool $30.00 $0.00 $83.00 $30.00 Renewed with transfer
coupons $51.00 $0.00 $108.00 $51.00 Renewed with transfer
credit $94.00 $0.00 $145.00 $94.00 Renewed with transfer
creditcard $141.00 $0.00 $190.00 $141.00 Renewed with transfer
cruises $49.00 $0.00 $100.00 $49.00 Renewed with transfer
dance $22.00 $0.00 $76.00 $22.00 Renewed with transfer
dating $49.00 $0.00 $100.00 $49.00 Renewed with transfer
de $9.00 $0.00 $9.00 $9.00 Renewed with transfer
deals $29.00 $0.00 $83.00 $29.00 Renewed with transfer
delivery $47.00 $0.00 $100.00 $47.00 Renewed with transfer
democrat $30.00 $0.00 $83.00 $30.00 Renewed with transfer
dental $47.00 $0.00 $100.00 $47.00 Renewed with transfer
diamonds $35.00 $0.00 $100.00 $35.00 Renewed with transfer
diet $19.00* $0.00 Not supported Not supported Not supported
digital $29.00 $0.00 $83.00 $29.00 Renewed with transfer
direct $29.00 $0.00 $83.00 $29.00 Renewed with transfer
directory $21.00 $0.00 $73.00 $21.00 Renewed with transfer
discount $29.00 $0.00 $83.00 $29.00 Renewed with transfer
dog $46.00 $0.00 $100.00 $46.00 Renewed with transfer
domains $32.00 $0.00 $83.00 $32.00 Renewed with transfer
education $21.00 $0.00 $73.00 $21.00 Renewed with transfer
email $25.00 $0.00 $73.00 $25.00 Renewed with transfer
energy $94.00 $0.00 $145.00 $94.00 Renewed with transfer
engineering $47.00 $0.00 $100.00 $47.00 Renewed with transfer
enterprises $32.00 $0.00 $83.00 $32.00 Renewed with transfer
equipment $21.00 $0.00 $79.00 $21.00 Renewed with transfer
es $10.00 $10.00 $10.00 $0.00 No change
estate $32.00 $0.00 $83.00 $32.00 Renewed with transfer
eu $13.00 $0.00 $13.00 $13.00 Renewed with transfer
events $30.00 $0.00 $83.00 $30.00 Renewed with transfer
exchange $29.00 $0.00 $83.00 $29.00 Renewed with transfer
expert $49.00 $0.00 $100.00 $49.00 Renewed with transfer
exposed $19.00 $0.00 $73.00 $19.00 Renewed with transfer
express $31.00 $0.00 $89.00 $31.00 Renewed with transfer
fail $29.00 $0.00 $83.00 $29.00 Renewed with transfer
farm $32.00 $0.00 $83.00 $32.00 Renewed with transfer
fi $24.00 $24.00 $24.00 $24.00 No change
finance $47.00 $0.00 $100.00 $47.00 Renewed with transfer
financial $47.00 $0.00 $100.00 $47.00 Renewed with transfer
fish $29.00 $0.00 $83.00 $29.00 Renewed with transfer
fitness $29.00 $0.00 $83.00 $29.00 Renewed with transfer
flights $49.00 $0.00 $100.00 $49.00 Renewed with transfer
florist $32.00 $0.00 $83.00 $32.00 Renewed with transfer
flowers $25.00 $0.00 $66.00 $25.00 Renewed with transfer
fm $92.00 $0.00 $123.00 $92.00 Renewed with transfer
football $19.00 $0.00 $73.00 $19.00 Renewed with transfer
forsale $29.00 $0.00 $83.00 $29.00 Renewed with transfer
foundation $30.00 $0.00 $83.00 $30.00 Renewed with transfer
fr $12.00 $12.00 $12.00 $12.00 Renewed with transfer
fund $47.00 $0.00 $100.00 $47.00 Renewed with transfer
furniture $47.00 $0.00 $100.00 $47.00 Renewed with transfer
futbol $12.00 $0.00 $66.00 $12.00 Renewed with transfer
fyi $20.00 $0.00 $79.00 $20.00 Renewed with transfer
gallery $21.00 $0.00 $73.00 $21.00 Renewed with transfer
gg $75.00 $0.00 $91.00 $75.00 Renewed with transfer
gift $20.00 $0.00 $60.00 $20.00 Renewed with transfer
gifts $19.00 $0.00 $83.00 $19.00 Renewed with transfer
glass $46.00 $0.00 $100.00 $46.00 Renewed with transfer
global $71.00 $0.00 $205.00 $71.00 Renewed with transfer
gold $101.00 $0.00 $157.00 $101.00 Renewed with transfer
golf $51.00 $0.00 $108.00 $51.00 Renewed with transfer
graphics $21.00 $0.00 $73.00 $21.00 Renewed with transfer
gratis $19.00 $0.00 $73.00 $19.00 Renewed with transfer
green $71.00 $0.00 $124.00 $71.00 Renewed with transfer
gripe $29.00 $0.00 $83.00 $29.00 Renewed with transfer
guide $29.00 $0.00 $83.00 $29.00 Renewed with transfer
guitars $30.00* $0.00 Not supported Not supported Not supported
guru $25.00 $0.00 $83.00 $25.00 Renewed with transfer
haus $29.00 $0.00 $83.00 $29.00 Renewed with transfer
healthcare $47.00 $0.00 $100.00 $47.00 Renewed with transfer
help $30.00 $0.00 $60.00 $30.00 Renewed with transfer
hiv $254.00 $0.00 $300.00 $254.00 Renewed with transfer
hockey $51.00 $0.00 $108.00 $51.00 Renewed with transfer
holdings $35.00 $0.00 $100.00 $35.00 Renewed with transfer
holiday $35.00 $0.00 $100.00 $35.00 Renewed with transfer
host $93.00 $0.00 $201.00 $93.00 Renewed with transfer
hosting $29.00* $0.00 Not supported Not supported Not supported
house $32.00 $0.00 $83.00 $32.00 Renewed with transfer
im $19.00 $19.00 $19.00 $0.00 No change
immo $29.00 $0.00 $83.00 $29.00 Renewed with transfer
immobilien $30.00 $0.00 $83.00 $30.00 Renewed with transfer
in $15.00 $0.00 $26.00 $15.00 Renewed with transfer
industries $29.00 $0.00 $83.00 $29.00 Renewed with transfer
info $12.00 $0.00 $70.00 $12.00 Renewed with transfer
ink $29.00 $0.00 $88.00 $29.00 Renewed with transfer
institute $21.00 $0.00 $73.00 $21.00 Renewed with transfer
insure $47.00 $0.00 $100.00 $47.00 Renewed with transfer
international $21.00 $0.00 $73.00 $21.00 Renewed with transfer
investments $94.00 $0.00 $145.00 $94.00 Renewed with transfer
io $39.00 $0.00 $39.00 $39.00 Renewed with transfer
irish $36.00 $0.00 $89.00 $36.00 Renewed with transfer
it $15.00 $0.00 $15.00 $15.00 Renewed with transfer
jewelry $51.00 $0.00 $108.00 $51.00 Renewed with transfer
jp $90.00 $0.00 $94.00 $90.00 No change
juegos $13.00* $0.00 Not supported Not supported Not supported
kaufen $30.00 $0.00 $83.00 $30.00 Renewed with transfer
kim $15.00 $0.00 $69.00 $15.00 Renewed with transfer
kitchen $46.00 $0.00 $100.00 $46.00 Renewed with transfer
kiwi $32.00 $0.00 $74.00 $32.00 Renewed with transfer
land $32.00 $0.00 $83.00 $32.00 Renewed with transfer
lease $47.00 $0.00 $100.00 $47.00 Renewed with transfer
legal $47.00 $0.00 $100.00 $47.00 Renewed with transfer
lgbt $43.00 $0.00 $55.00 $43.00 Renewed with transfer
life $29.00 $0.00 $83.00 $29.00 Renewed with transfer
lighting $21.00 $0.00 $73.00 $21.00 Renewed with transfer
limited $29.00 $0.00 $83.00 $29.00 Renewed with transfer
limo $35.00 $0.00 $100.00 $35.00 Renewed with transfer
link $10.00 $0.00 $51.00 $10.00 Renewed with transfer
live $23.00 $0.00 $82.00 $23.00 Renewed with transfer
loan $31.00 $0.00 $89.00 $31.00 Renewed with transfer
loans $94.00 $0.00 $145.00 $94.00 Renewed with transfer
lol $31.00 $0.00 $74.00 $31.00 Renewed with transfer
maison $49.00 $0.00 $100.00 $49.00 Renewed with transfer
management $21.00 $0.00 $73.00 $21.00 Renewed with transfer
marketing $32.00 $0.00 $83.00 $32.00 Renewed with transfer
mba $31.00 $0.00 $89.00 $31.00 Renewed with transfer
me $17.00 $0.00 $47.00 $17.00 Renewed with transfer
me.uk $8.00 $0.00 $8.00 $0.00 No change
media $29.00 $0.00 $83.00 $29.00 Renewed with transfer
memorial $47.00 $0.00 $100.00 $47.00 Renewed with transfer
mobi $12.00 $12.00 $70.00 $12.00 Renewed with transfer
moda $22.00 $0.00 $83.00 $22.00 Renewed with transfer
money $29.00 $0.00 $83.00 $29.00 Renewed with transfer
mortgage $43.00 $0.00 $96.00 $43.00 Renewed with transfer
movie $306.00 $0.00 $355.00 $306.00 Renewed with transfer
mx $34.00 $0.00 $67.00 $34.00 Renewed with transfer
name $9.00 $0.00 $64.00 $9.00 Renewed with transfer
net $11.00 $0.00 $67.00 $11.00 Renewed with transfer
net.au $15.00 $40.00 $60.00 $0.00 No change
net.nz $24.00 $0.00 $24.00 $24.00 Renewed with transfer
network $19.00 $0.00 $73.00 $19.00 Renewed with transfer
news $23.00 $0.00 $82.00 $23.00 Renewed with transfer
ninja $18.00 $0.00 $72.00 $18.00 Renewed with transfer
nl $10.00 $10.00 $10.00 $10.00 Renewed with transfer
onl $15.00 $0.00 $83.00 $15.00 Renewed with transfer
online $39.00 $0.00 $126.00 $39.00 Renewed with transfer
org $12.00 $0.00 $69.00 $12.00 Renewed with transfer
org.nz $24.00 $0.00 $24.00 $24.00 Renewed with transfer
org.uk $9.00 $0.00 $9.00 $0.00 No change
partners $49.00 $0.00 $100.00 $49.00 Renewed with transfer
parts $29.00 $0.00 $83.00 $29.00 Renewed with transfer
photo $30.00 $0.00 $69.00 $30.00 Renewed with transfer
photography $21.00 $0.00 $73.00 $21.00 Renewed with transfer
photos $21.00 $0.00 $59.00 $21.00 Renewed with transfer
pics $30.00 $0.00 $60.00 $30.00 Renewed with transfer
pictures $10.00 $0.00 $65.00 $10.00 Renewed with transfer
pink $15.00 $0.00 $69.00 $15.00 Renewed with transfer
pizza $47.00 $0.00 $100.00 $47.00 Renewed with transfer
place $29.00 $0.00 $83.00 $29.00 Renewed with transfer
plumbing $46.00 $0.00 $100.00 $46.00 Renewed with transfer
plus $31.00 $0.00 $89.00 $31.00 Renewed with transfer
poker $43.00 $0.00 $96.00 $43.00 Renewed with transfer
porn $100.00 $0.00 $160.00 $100.00 Renewed with transfer
pro $14.00 $0.00 $69.00 $14.00 Renewed with transfer
productions $30.00 $0.00 $83.00 $30.00 Renewed with transfer
properties $30.00 $0.00 $83.00 $30.00 Renewed with transfer
property $29.00* $0.00 Not supported Not supported Not supported
pub $22.00 $0.00 $83.00 $22.00 Renewed with transfer
qa $64.00* $64.00 Not supported Not supported Not supported
qpon $15.00 $0.00 $69.00 $15.00 Renewed with transfer
recipes $35.00 $0.00 $100.00 $35.00 Renewed with transfer
red $15.00 $0.00 $69.00 $15.00 Renewed with transfer
reise $101.00 $0.00 $157.00 $101.00 Renewed with transfer
reisen $19.00 $0.00 $73.00 $19.00 Renewed with transfer
rentals $30.00 $0.00 $83.00 $30.00 Renewed with transfer
repair $32.00 $0.00 $83.00 $32.00 Renewed with transfer
report $19.00 $0.00 $73.00 $19.00 Renewed with transfer
republican $29.00 $0.00 $83.00 $29.00 Renewed with transfer
restaurant $47.00 $0.00 $100.00 $47.00 Renewed with transfer
reviews $22.00 $0.00 $76.00 $22.00 Renewed with transfer
rip $17.00 $0.00 $72.00 $17.00 Renewed with transfer
rocks $12.00 $0.00 $66.00 $12.00 Renewed with transfer
ru $36.00* $36.00 Not supported Not supported Not supported
ruhr $30.00 $0.00 $226.00 $30.00 Renewed with transfer
run $20.00 $0.00 $79.00 $20.00 Renewed with transfer
sale $29.00 $0.00 $83.00 $29.00 Renewed with transfer
sarl $29.00 $0.00 $83.00 $29.00 Renewed with transfer
school $29.00 $0.00 $83.00 $29.00 Renewed with transfer
schule $19.00 $0.00 $73.00 $19.00 Renewed with transfer
se $23.00 $23.00 $23.00 $0.00 No change
services $29.00 $0.00 $83.00 $29.00 Renewed with transfer
sex $100.00 $0.00 $160.00 $100.00 Renewed with transfer
sexy $65.00 $0.00 $95.00 $65.00 Renewed with transfer
sg $47.00* $47.00 Not supported Not supported Not supported
sh $48.00 $48.00 $48.00 $0.00 No change
shiksha $16.00 $0.00 $69.00 $16.00 Renewed with transfer
shoes $46.00 $0.00 $100.00 $46.00 Renewed with transfer
show $31.00 $0.00 $89.00 $31.00 Renewed with transfer
singles $30.00 $0.00 $83.00 $30.00 Renewed with transfer
soccer $20.00 $0.00 $79.00 $20.00 Renewed with transfer
social $32.00 $0.00 $83.00 $32.00 Renewed with transfer
solar $46.00 $0.00 $100.00 $46.00 Renewed with transfer
solutions $25.00 $0.00 $73.00 $25.00 Renewed with transfer
studio $23.00 $0.00 $82.00 $23.00 Renewed with transfer
style $29.00 $0.00 $83.00 $29.00 Renewed with transfer
sucks $282.00 $0.00 $313.00 $282.00 Renewed with transfer
supplies $19.00 $0.00 $73.00 $19.00 Renewed with transfer
supply $19.00 $0.00 $73.00 $19.00 Renewed with transfer
support $21.00 $0.00 $73.00 $21.00 Renewed with transfer
surgery $47.00 $0.00 $100.00 $47.00 Renewed with transfer
systems $21.00 $0.00 $73.00 $21.00 Renewed with transfer
tattoo $45.00 $0.00 $75.00 $45.00 Renewed with transfer
tax $47.00 $0.00 $100.00 $47.00 Renewed with transfer
taxi $51.00 $0.00 $108.00 $51.00 Renewed with transfer
team $31.00 $0.00 $89.00 $31.00 Renewed with transfer
technology $21.00 $0.00 $73.00 $21.00 Renewed with transfer
tennis $47.00 $0.00 $100.00 $47.00 Renewed with transfer
theater $51.00 $0.00 $108.00 $51.00 Renewed with transfer
tienda $50.00 $0.00 $100.00 $50.00 Renewed with transfer
tips $21.00 $0.00 $59.00 $21.00 Renewed with transfer
tires $94.00 $0.00 $145.00 $94.00 Renewed with transfer
today $21.00 $0.00 $73.00 $21.00 Renewed with transfer
tools $29.00 $0.00 $83.00 $29.00 Renewed with transfer
tours $51.00 $0.00 $108.00 $51.00 Renewed with transfer
town $29.00 $0.00 $83.00 $29.00 Renewed with transfer
toys $46.00 $0.00 $100.00 $46.00 Renewed with transfer
trade $29.00 $0.00 $83.00 $29.00 Renewed with transfer
training $27.00 $0.00 $83.00 $27.00 Renewed with transfer
tv $32.00 $0.00 $89.00 $32.00 Renewed with transfer
uk $9.00 $0.00 $9.00 $0.00 No change
university $47.00 $0.00 $100.00 $47.00 Renewed with transfer
uno $30.00 $0.00 $69.00 $30.00 Renewed with transfer
us $15.00 $0.00 $64.00 $15.00 Renewed with transfer
vacations $35.00 $0.00 $83.00 $35.00 Renewed with transfer
vc $33.00 $0.00 $137.00 $30.00 Renewed with transfer
vegas $57.00 $0.00 $110.00 $57.00 Renewed with transfer
ventures $35.00 $0.00 $100.00 $35.00 Renewed with transfer
vg $35.00 $35.00 $96.00 $35.00 Renewed with transfer
viajes $49.00 $0.00 $100.00 $49.00 Renewed with transfer
video $22.00 $0.00 $76.00 $22.00 Renewed with transfer
villas $35.00 $0.00 $100.00 $35.00 Renewed with transfer
vision $29.00 $0.00 $83.00 $29.00 Renewed with transfer
voyage $50.00 $0.00 $100.00 $50.00 Renewed with transfer
watch $37.00 $0.00 $83.00 $37.00 Renewed with transfer
website $23.00 $0.00 $78.00 $23.00 Renewed with transfer
wien $29.00 $0.00 $102.00 $29.00 Renewed with transfer
wiki $30.00 $0.00 $88.00 $30.00 Renewed with transfer
works $30.00 $0.00 $83.00 $30.00 Renewed with transfer
world $29.00 $0.00 $83.00 $29.00 Renewed with transfer
wtf $29.00 $0.00 $83.00 $29.00 Renewed with transfer
xyz $12.00 $0.00 $80.00 $12.00 Renewed with transfer
zone $32.00 $0.00 $83.00 $32.00 Renewed with transfer"""


tld_prices = [[w[0], w[1]] for w in [l.split(" ") for l in AWS_DOMAINS.split("\n")]]


def dig_domain(domain):
    return subprocess.check_output(["dig", domain], universal_newlines=True)


def is_available(domain, verbose=False):
    o = dig_domain(domain)
    if verbose:
        print(o)
    return "ANSWER: 0," in o


if __name__ == "__main__":
    parser = argparse.ArgumentParser("python r53dig.py")
    parser.add_argument("--verbose", "-v", default=0, action="count")
    parser.add_argument("--max-len-tld", "-m", dest="max_len_tld", type=int, default=4)
    parser.add_argument("domain", type=str, help="domain name to check")
    args = parser.parse_args()
    for p in tld_prices:
        tld = p[0]
        # don't check domains greater than max-length tld:
        if len(tld) > args.max_len_tld:
            continue
        price = p[1]
        domain = f"{args.domain}.{tld}"
        domain_and_price = f"{domain.ljust(16)} {price.ljust(8)}"

        print(domain_and_price, end=" ")
        if is_available(domain, args.verbose):
            print("AVAILABLE")
        else:
            print("not avail")
