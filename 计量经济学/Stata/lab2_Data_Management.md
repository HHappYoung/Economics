# Lab2 Data Management

## 三

### 1.数学表达式

```stata
display 5^2
```

## 四

```stata
bysort race: gen gid = _n

egen avg_w_r = mean(wage), by(race)

egen avg_w_r = mean(anualwage), by(female)
```