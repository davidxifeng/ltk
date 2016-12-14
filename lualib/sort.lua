-- Wed 21:08 Dec 14 2016
-- 两个简单的排序算法

-- inplace 稳定的简单排序 插入排序
local function simple_stable_insert_sort(list, comp)
  for i = 1, # list - 1 do
    for j = i + 1, 2, -1 do
      local k = j - 1
      local lj, lk = list[j], list[k]
      if comp(lj, lk) then list[j], list[k] = lk, lj end
    end
  end
end

-- inplace 稳定的简单排序 冒泡排序
-- 有序的情况下,比较次数少
local function simple_stable_bubble_sort(list, comp)
  for i = 1, # list do
    local stop = true
    for j = # list, i + 1, -1 do
      local k = j - 1
      local lj, lk = list[j], list[k]
      if comp(lj, lk) then
        stop, list[j], list[k] = false, lk, lj
      end
    end
    if stop then break end
  end
end
